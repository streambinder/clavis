{ config, pkgs, ... }:

{
  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;

  home.stateVersion = "20.03";

  home.packages = with pkgs; [
    brave
    ffmpeg
    gimp
    gnome3.gnome-tweaks
    gnupg
    keepassxc
    imagemagick
    megacmd
    nixfmt
    pywal
    spotify
    tdesktop
    tilix
    unzip
    vscodium
    yadm
    youtube-dl
  ];

  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    oh-my-zsh = {
      enable = true;
      theme = "sorin";
    };
    initExtra = "source $HOME/.shrc";
  };

  programs.git = {
    enable = true;
    userName = "streambinder";
    userEmail = "posta@davidepucci.it";
  };

  programs.gnome-terminal = { enable = false; };

  services.gpg-agent = { enable = true; };

  home.file.".config/systemd/user/wal-flusher.sh".text = ''
    cd "$HOME"

    if ! test wal; then
    	echo "Wal not installed. Skipping."
    	exit
    fi

    cfg_wallpaper_path="$HOME/.cache/wal/wallpaper.md5"
    if [ -f "$cfg_wallpaper_path" ]; then
    	cfg_wallpaper_md5="$(cat $cfg_wallpaper_path)"
    fi

    now_wallpaper_path="$(dconf dump /org/gnome/desktop/background/ | awk -F'file://' '/^picture-uri=/ {print $2}' | sed s/\'//g)"
    if [ -z "$now_wallpaper_path" ]; then
    	echo "Unable to identify background image"
    	exit
    else
    	now_wallpaper_md5="$(md5sum "$now_wallpaper_path" | awk '{print $1}')"
    fi

    if [ "$cfg_wallpaper_md5" = "$now_wallpaper_md5" ]; then
    	echo "Wal configuration files already up-to-date"
    else
    	wal -c
    	wal -i "$now_wallpaper_path" -n
    	echo "$now_wallpaper_md5" > "$cfg_wallpaper_path"
    	echo "Updated Wal configuration files"
    fi
  '';

  systemd.user = {
    startServices = true;
    services = {
      mega-sync = {
        Unit = { Description = "MEGA sync service"; };
        Service = {
          Type = "simple";
          ExecStart = "${pkgs.megacmd}/bin/mega-cmd-server";
          Restart = "always";
        };
        Install = { WantedBy = [ "default.target" ]; };
      };
      paperboy = {
        Unit = { Description = "PaperBoy service"; };
        Service = {
          Type = "simple";
          ExecStart = "paperboy -c %h/.config/paperboy";
        };
      };
      yadm-updater = {
        Unit = { Description = "YADM config updater service"; };
        Service = {
          Type = "simple";
          ExecStart =
            "${pkgs.megacmd}/bin/yadm pull && ${pkgs.megacmd}/bin/yadm bootstrap";
        };
      };
      wal-flusher = {
        Unit = { Description = "Wal configuration files flusher service"; };
        Service = {
          Type = "simple";
          ExecStart =
            "${pkgs.bash}/bin/bash %h/.config/systemd/user/wal-flusher.sh";
        };
      };
    };
    timers = {
      paperboy = {
        Unit = { Description = "PaperBoy timer"; };
        Timer = {
          Unit = "paperboy.service";
          OnCalendar = "*-*-* *:00/5";
        };
        Install = { WantedBy = [ "timers.target" ]; };
      };
      yadm-updater = {
        Unit = { Description = "YADM config updater timer"; };
        Timer = {
          Unit = "yadm-updater.service";
          OnCalendar = "*-*-* *:00:00";
        };
        Install = { WantedBy = [ "timers.target" ]; };
      };
      wal-flusher = {
        Unit = { Description = "Wal configuration files flusher timer"; };
        Timer = {
          Unit = "wal-flusher.service";
          OnCalendar = "*-*-* *:*:00";
        };
        Install = { WantedBy = [ "timers.target" ]; };
      };

    };
  };

}
