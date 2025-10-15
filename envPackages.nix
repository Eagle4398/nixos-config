{ pkgs, unstablePkgs }:
let
  packages = with pkgs; [
    gparted
    unstablePkgs.yt-dlp
    qdirstat
    xorg.xhost
    qimgv
    # litarvan-theme
    unstablePkgs.texliveFull
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
    clang
    nodejs
    shfmt
    unstablePkgs.neovim
    vim
    wget
    git
    curl
    zip
    unzip
    xclip
    spice
    spice-vdagent
    jq
    openssh
    unstablePkgs.bitwarden
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
  ];
in packages
