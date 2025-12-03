{ pkgs, unstablePkgs }:
let
  packages = with pkgs; [
    unstablePkgs.yt-dlp
    xorg.xhost
    qimgv
    # litarvan-theme
    ryzenadj
    # dolphin mtp
    libmtp
    kdePackages.kio-extras
    # dolphin icon support
    kdePackages.gwenview
    kdePackages.qtsvg
    kdePackages.ark
    libsForQt5.breeze-icons
    numlockx
    kbd
    #
    (lib.hiPrio clang)
    nodejs
    xidlehook
    shfmt
    unstablePkgs.neovim
    vim
    wget
    git
    curl
    zip
    unzip
    # xclip
    spice
    spice-vdagent
    jq
    openssh
    fzf
    uv
    python3
    gcc
    findutils
    pciutils
    openssl
    rustc
    file
    cargo
    gnumake
    acpi
    ripgrep
    brightnessctl
    e2fsprogs
  ];
in packages
