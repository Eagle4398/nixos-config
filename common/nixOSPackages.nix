{ pkgs, unstablePkgs }:
let
  packages = with pkgs; [
    # octaveFull
    unstablePkgs.texliveFull
    xclip
    alsa-utils
    gnome-keyring 
  ];
in packages
