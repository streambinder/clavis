{ config, pkgs, ... }:

{
  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;

  home.stateVersion = "20.03";

  home.packages = [
    pkgs.brave
    pkgs.ffmpeg
    pkgs.gimp
    pkgs.gnome3.gnome-tweaks
    pkgs.gnupg
    pkgs.keepassxc
    pkgs.imagemagick
    pkgs.megacmd
    pkgs.spotify
    pkgs.tdesktop
    pkgs.tilix
    pkgs.unzip
    pkgs.vscodium
    pkgs.yadm
    pkgs.youtube-dl
  ];

  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "sorin";
    };
  };

  programs.git = {
    enable = true;
    userName = "streambinder";
    userEmail = "posta@davidepucci.it";
  };

}
