{ pkgs, unstablePkgs }:
let
  packages = with pkgs; [
    j4-dmenu-desktop
    dmenu
    hsetroot
    i3status
    # i3lock
    networkmanagerapplet
    i3blocks
    xss-lock
    xterm
    unstablePkgs.texliveFull
    unstablePkgs.texlivePackages.noto-emoji
    # # Don't mix system "drivers" with nix packages. No gooood.
    # alsa-utils
    # alsa-plugins
  ];
in packages
