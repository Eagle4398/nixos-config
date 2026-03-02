{ pkgs, unstablePkgs }:
let
  packages = with pkgs; [
    udiskie
    tree-sitter
    unstablePkgs.chromedriver
    tree
    i3
    # discord
    tmux
    xdotool
    unstablePkgs.typst
    lxqt.pavucontrol-qt
    arandr
    autorandr
    cachix
    nix-serve-ng
    rclone
    ffmpeg
    nixd
    rustfmt
  ];
in packages
