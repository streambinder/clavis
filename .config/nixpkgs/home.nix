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

  services.gpg-agent = {
      enable = true;
  };

}
