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
    kdePackages.kservice # Provides kbuildsycoca6
    kdePackages.kio # File handling framework
    # kdePackages.plasma-workspace
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

    seahorse
    libsecret

    libnvidia-container

    fd
    bandwhich

    distrobox

    # kdePackages.kio-gdrive
    # kdePackages.kaccounts-integration
    # kdePackages.kaccounts-providers
    # kdePackages.kcmutils
    # kdePackages.systemsettings # Required to actually sign into your Google account
    # # If you don't have a keyring/wallet, tokens won't save
    # kdePackages.signond
    # kdePackages.kwallet
    # kdePackages.kwallet-pam
  ];
in packages
