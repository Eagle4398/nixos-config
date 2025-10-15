{ pkgs, unstablePkgs }:
let
  packages = with pkgs; [
    octaveFull
    unstablePkgs.texliveFull
  ];
in packages
