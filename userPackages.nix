{ pkgs, unstablePkgs }:
let
  packages = with pkgs; [
    octaveFull
    udiskie
    bemoji
    rofimoji
    emojipick
    smile
    unstablePkgs.google-chrome
    unstablePkgs.chromedriver
    anki-bin
    tree
    i3
    alacritty
    jetbrains-toolbox
    vscode
    unstablePkgs.signal-desktop
    # discord
    tmux
    xdotool
    qutebrowser
    unstablePkgs.typst
    flameshot
    zathura
    lxqt.pavucontrol-qt
    alsa-utils
    zotero
    arandr
    autorandr
    # unstable.brave # loaded through home-manager for extensions
    jetbrains-toolbox
    kdePackages.dolphin
    pinta
    unstablePkgs.obsidian
    cachix
  ];
in packages
