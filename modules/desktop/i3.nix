{ config, lib, pkgs, ... }:

{
  services.displayManager.defaultSession = "none+i3";
  services.xserver.desktopManager.xterm.enable = false;
  services.xserver.windowManager.i3 = {
    enable = true;
    extraPackages = with pkgs; [
      j4-dmenu-desktop
      dmenu
      hsetroot
      i3status
      i3lock
      networkmanagerapplet
      i3blocks
      xss-lock
    ];
  };

  # I don't actually know if this is necessary for i3 
  programs.dconf.enable = true;

  # i think this solved an i3 issue bit I don't remember anymore
  environment.pathsToLink = [ "/libexec" ];
}
