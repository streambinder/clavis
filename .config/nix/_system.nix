{ config, pkgs, ... }:

{
  system.stateVersion = "20.03";

  imports = [
    # user
    ./_user.nix
  ];

  # Networking
  networking.useDHCP = false;
  networking.networkmanager.enable = true;

  # Timezone
  # time.timeZone = "Europe/Rome";

  # System packages
  environment.systemPackages = with pkgs; [
    binutils
    git
    gnomeExtensions.night-theme-switcher
    go
    ntfs3g
    python39
    vim
    wget
  ];
  programs.zsh.enable = true;
  programs.seahorse.enable = false;
  programs.geary.enable = false;
  services.gnome3.sushi.enable = false;
  services.gnome3.tracker.enable = false;
  services.gnome3.tracker-miners.enable = false;
  environment.gnome3.excludePackages = with pkgs; [
    epiphany
    gnome3.gnome-characters
    gnome3.gnome-getting-started-docs
    gnome3.gnome-software
    gnome3.gnome-weather
    simple-scan
    xterm
  ];
  nixpkgs.config.allowUnfree = true;
  nixpkgs.overlays = [ (import ./_pkgs) ];

  # Mouse
  services.xserver.libinput = {
    enable = true;
    tapping = true;
  };

  # Desktop
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    displayManager.gdm.wayland = false;
    desktopManager.gnome3.enable = true;
    desktopManager.gnome3.extraGSettingsOverrides = ''
      [org.gnome.desktop.peripherals.touchpad]
      click-method='default'
      [org.gnome.shell.app-switcher]
      current-workspace-only=true
      [org.gnome.desktop.wm.keybindings]
      switch-applications=[]
      switch-applications-backward=[]
      switch-windows=['<Alt>Tab', '<Super>Tab']
      switch-windows-backward=['<Alt><Shift>Tab', '<Super><Shift>Tab']
    '';
    layout = "us";
    xkbOptions = "alt-intl";
  };
  console.useXkbConfig = true;

  # Sudo
  security.sudo.enable = true;
  security.sudo.extraConfig = ''
    %wheel      ALL=(ALL:ALL) NOPASSWD: ALL
  '';

}
