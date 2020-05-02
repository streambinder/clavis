{ config, pkgs, ... }:

{
  system.stateVersion = "20.03";

  imports =
    [
      ./hardware-configuration.nix
      <home-manager/nixos> 
    ];

  # Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.device = "/dev/sda";
  boot.initrd.luks.devices.root = {
    device = "/dev/sda3";
    preLVM = true;
  };

  # Networking
  networking.hostName = "crow";
  networking.useDHCP = false;
  networking.interfaces.enp0s25.useDHCP = true;
  networking.interfaces.wlp3s0.useDHCP = true;
  networking.networkmanager.enable = true;

  # Timezone
  # time.timeZone = "Europe/Rome";

  # System packages
  environment.systemPackages = with pkgs; [
    git
    go
    ntfs3g
    python39
    vim
    wget
    zsh
  ];
  programs.seahorse.enable = false;
  services.gnome3.sushi.enable = false;
  services.gnome3.tracker.enable = false;
  services.gnome3.tracker-miners.enable = false;
  environment.gnome3.excludePackages = [
    pkgs.gnome3.epiphany
    pkgs.gnome3.geary
    pkgs.gnome3.gnome-characters
    pkgs.gnome3.gnome-getting-started-docs
    pkgs.gnome3.gnome-software
    pkgs.gnome3.gnome-terminal
    pkgs.gnome3.gnome-weather
    pkgs.gnome3.simple-scan
  ];

  # Mouse
  services.xserver.libinput = {
    enable = true;
    tapping = true;
  };

  # Desktop
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome3.enable = true;
    desktopManager.gnome3.extraGSettingsOverrides = ''
      [org.gnome.desktop.peripherals.touchpad]
      click-method='default'
    '';
    layout = "us";
    xkbOptions = "alt-intl";
  };
  console.useXkbConfig = true;

  # Users
  users.extraUsers.streambinder = {
    name = "streambinder";
    description = "Davide Pucci";
    group = "users";
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "disk"
      "audio"
      "video"
      "networkmanager"
      "systemd-journal"
    ];
    createHome = true;
    uid = 1000;
    home = "/home/streambinder";
    shell = "/run/current-system/sw/bin/zsh";
  };

}
