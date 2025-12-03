{ pkgs, unstablePkgs }:
let
  packages = with pkgs; [
    flameshot
    gparted
    qdirstat
    unstablePkgs.bitwarden-desktop
    bemoji
    rofimoji
    emojipick
    smile
    jetbrains-toolbox
    vscode
    unstablePkgs.google-chrome
    anki-bin
    unstablePkgs.signal-desktop
    qutebrowser
    zathura
    zotero
    jetbrains-toolbox
    kdePackages.dolphin
    pinta
    unstablePkgs.obsidian
    alacritty
    qbittorrent
  ];
in packages
