{ config, pkgs, ... }:

{

  imports = [
    (import "${
        builtins.fetchTarball
        "https://github.com/rycee/home-manager/archive/master.tar.gz"
      }/nixos")
  ];

  # User definition
  users.extraUsers.streambinder = {
    name = "streambinder";
    description = "Davide Pucci";
    group = "users";
    isNormalUser = true;
    extraGroups =
      [ "wheel" "disk" "audio" "video" "networkmanager" "systemd-journal" ];
    createHome = true;
    uid = 1000;
    home = "/home/streambinder";
    shell = "${pkgs.zsh}/bin/zsh";
  };

  # Home Manager
  home-manager.users.streambinder = {

    programs.home-manager.enable = true;

    home.stateVersion = "20.03";

    home.packages = with pkgs; [
      chromium
      ffmpeg
      gimp
      gnupg
      keepassxc
      imagemagick
      megacmd
      nixfmt
      paperboy
      pywal
      spotify
      tdesktop
      tilix
      transmission-gtk
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

    programs.vim = {
      enable = true;
      extraConfig = ''
        " move backup files to /tmp
        set backupdir-=.
        set backupdir^=~/tmp,/tmp

        " show (relative) line numbers
        set relativenumber

        " disable visual mode on mouse select
        set mouse-=a 
      '';
    };

    programs.vscode = {
      enable = true;
      package = pkgs.vscodium;
      userSettings = {
        "workbench.startupEditor" = "newUntitledFile";
        "editor.tabSize" = 4;
        "python.formatting.autopep8Path" =
          "/run/current-system/sw/bin/autopep8";
        "go.gopath" = "/home/streambinder/go";
      };
      extensions = [ ];
    };

    programs.gnome-terminal = { enable = false; };

    services.gpg-agent = { enable = true; };

    home.file.".hidden".text = ''
      go
    '';

    home.file.".shrc".text = ''
      # external imports
      [ -f $HOME/.shrc_secure ] && source "$HOME/.shrc_secure"
      [ -d $HOME/.cache/wal ] && (cat ~/.cache/wal/sequences &)

      ## exports
      # system
      export EDITOR="vi"
      # customizations
      export SVN_EDITOR="$EDITOR"
      export GOPATH="$HOME/go"
      # path
      export PATH=$HOME/.local/bin:$GOPATH/bin:$HOME/.npm/bin:/usr/local/sbin:/usr/local/bin:$PATH

      ## aliases
      # system
      alias ls="ls --color=auto"
      alias grep="grep --color=auto"
      alias egrep="egrep --color=auto"
      alias fgrep="fgrep --color=auto"
      # customizations
      alias nix-update="sudo nixos-rebuild -I nixos-config=$HOME/.nix/crow.nix switch"
      alias npm="npm -g"
      alias publicip="dig +short myip.opendns.com @resolver1.opendns.com"
      alias vi="vim"
    '';

    home.file.".config/gtk-3.0/gtk.css".text = ''
      VteTerminal, TerminalScreen, vte-terminal {
          padding: 25px 25px 25px 25px;
          -VteTerminal-inner-border: 25px 25px 25px 25px;
      }
    '';

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
            ExecStart = "${pkgs.paperboy}/bin/paperboy -c %h/.config/paperboy";
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
  };

}
