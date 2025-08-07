{ config, lib, pkgs, username, unstablePkgs, ... }:
let
  nature-backgrounds = pkgs.stdenvNoCC.mkDerivation {
    name = "nature-images";
    src = pkgs.fetchurl {
      url =
        "https://www.dropbox.com/scl/fi/t6gnddx3lgrov56nj30de/nature-images.zip?rlkey=0t2jo103z63udj6emaiewgsth&st=y3poqskl&dl=1";
      sha256 = "sha256-XF3pPcVRE84wnesxO8aDFpsL81NK2YBWfnDr6ge2+SY=";
    };
    nativeBuildInputs = [ pkgs.unzip ];
    dontUnpack = true;
    buildPhase = ''
      unzip $src
    '';
    installPhase = ''
      mkdir -p $out
      cp -r * $out/
    '';
  };
  litarvan-theme = pkgs.callPackage (pkgs.fetchFromGitHub {
    owner = "Eagle4398";
    repo = "sea-greeter-lightdm-webkit-theme-litarvan-nixpkg";
    rev = "5ffcbd3a595c82fcef87f02a4ed9509fe62b8db8";
    sha256 = "sha256-W20hbwRqaoRAEHpmFgyL9Q+Wf8neMOQPkWeq/k72mhg=";
  } + /litarvan-theme.nix) { };
  sea-greeter = pkgs.callPackage (pkgs.fetchFromGitHub {
    owner = "Eagle4398";
    repo = "sea-greeter-lightdm-webkit-theme-litarvan-nixpkg";
    rev = "5ffcbd3a595c82fcef87f02a4ed9509fe62b8db8";
    sha256 = "sha256-W20hbwRqaoRAEHpmFgyL9Q+Wf8neMOQPkWeq/k72mhg=";
  } + /sea-greeter.nix) {
    theme = litarvan-theme;
    backgrounds = nature-backgrounds;
  };

in {
  imports = [
    # # Used to keep it at system level, but don't want impure flakes 
    # /etc/nixos/hardware-configuration.nix

    # # necessary without flake import
    # (import "${home-manager}/nixos")
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes " ];

  # Caches for fast downloads
  # Pretty sure that cache.nixos is not necessary to do explicitly
  nix.settings.substituters = [
    "https://cache.nixos.org/"
    "https://cuda-maintainers.cachix.org"
    "https://nix-community.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];

  # Windows drives
  boot.supportedFilesystems = [ "ntfs" ];

  # Numlock on by default
  boot.initrd.preLVMCommands = ''
    ${pkgs.kbd}/bin/setleds +num
  '';
  services.xserver.displayManager.setupCommands = ''
    ${pkgs.numlockx}/bin/numlockx on
  '';

  # ssh sometimes causes issues over ipv6
  boot.kernelParams = lib.mkAfter [ "ipv6.disable=1" ];

  # Networkmanager. 
  networking.networkmanager.enable = true;

  # Locales
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "de_DE.UTF-8";
  console = {
    # tty font outside of i3
    font = "Lat2-Terminus16";

    # # Get settings from Xkb
    #    keyMap = "us";
    useXkbConfig = true;
  };

  services.xserver.displayManager.lightdm = {
    enable = true;
    greeter.name = "sea-greeter";
    greeter.package = sea-greeter;
  };

  # x11 / i3 setup
  services.xserver.enable = true;
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
  programs.xss-lock = { enable = true; };
  services.xserver.xkb = {
    layout = "us,de";
    variant = "dvorak,";
    # Composes produces euro with (comp)e= 
    options = "caps:escape,compose:ralt,grp:win_space_toggle";

  };
  services.xserver.xautolock.time = 20;
  # I don't actually know if this is necessary for i3 
  programs.dconf.enable = true;

  # mouse acceleration creates inconsistencies on nvidia hidpi. I also hate it.
  # interestingly: https://www.youtube.com/watch?v=1oFy4X48dXM
  services.libinput = {
    enable = true;
    mouse.accelProfile = "flat";
  };

  # If you run your system through a QEMU VM spice-vdagent is necessary for 
  # clipboard sharing among other things
  # this is nice if you want to try building your nixOS distro from another 
  # distro using raw disk access. Don't ever parallel write-mount partitions
  # though, you'll corrupt them.
  services.spice-vdagentd.enable = true;

  # Enable CUPS to print
  services.printing.enable = true;
  # USB Mounting
  services.gvfs.enable = true;

  # Trying not to touch this, I had a hellish time getting all of this to work
  services.pulseaudio.enable = true;
  services.pulseaudio.support32Bit = true;
  services.pipewire.enable = false;
  services.pipewire.audio.enable = false;
  services.pipewire.alsa.enable = false;
  services.pipewire.alsa.support32Bit = false;
  services.pipewire.pulse.enable = false;

  # Reduce boottime by not waiting for network?
  systemd.services.NetworkManager-wait-online.enable = false;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "audio" ];
    packages = with pkgs; [
      unstablePkgs.google-chrome
      unstablePkgs.chromedriver
      anki-bin
      tree
      i3
      alacritty
      jetbrains-toolbox
      vscode
      unstablePkgs.signal-desktop
      discord
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
  };

  # why not
  programs.firefox.enable = true;

  # java
  programs.java = {
    enable = true;
    package = pkgs.jdk21;
  };

  # i think this solved an i3 issue bit I don't remember anymore
  environment.pathsToLink = [ "/libexec" ];
  # packages
  environment.systemPackages = with pkgs; [
    xorg.xhost
    qimgv
    # litarvan-theme
    unstablePkgs.texliveFull
    ryzenadj
    # dolphin mtp
    libmtp
    kdePackages.kio-extras
    # dolphin icon support
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

  # this is literally just for JetBrains shortcuts to work.
  # the launch scripts requires all of the dependencies in accessible in lib
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    SDL
    SDL2
    SDL2_image
    SDL2_mixer
    SDL2_ttf
    SDL_image
    SDL_mixer
    SDL_ttf
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    bzip2
    cairo
    cups
    curlWithGnuTls
    dbus
    dbus-glib
    desktop-file-utils
    e2fsprogs
    expat
    flac
    fontconfig
    freeglut
    freetype
    fribidi
    fuse
    fuse3
    gdk-pixbuf
    glew110
    glib
    gmp
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-ugly
    gst_all_1.gstreamer
    gtk2
    harfbuzz
    icu
    keyutils.lib
    libGL
    libGLU
    libappindicator-gtk2
    libcaca
    libcanberra
    libcap
    libclang.lib
    libdbusmenu
    libdrm
    libgcrypt
    libgpg-error
    libidn
    libjack2
    libjpeg
    libmikmod
    libogg
    libpng12
    libpulseaudio
    librsvg
    libsamplerate
    libthai
    libtheora
    libtiff
    libudev0-shim
    libusb1
    libuuid
    libvdpau
    libvorbis
    libvpx
    libxcrypt-legacy
    libxkbcommon
    libxml2
    mesa
    nspr
    nss
    openssl
    p11-kit
    pango
    pixman
    python3
    speex
    stdenv.cc.cc
    tbb
    udev
    vulkan-loader
    wayland
    xorg.libICE
    xorg.libSM
    xorg.libX11
    xorg.libXScrnSaver
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXft
    xorg.libXi
    xorg.libXinerama
    xorg.libXmu
    xorg.libXrandr
    xorg.libXrender
    xorg.libXt
    xorg.libXtst
    xorg.libXxf86vm
    xorg.libpciaccess
    xorg.libxcb
    xorg.xcbutil
    xorg.xcbutilimage
    xorg.xcbutilkeysyms
    xorg.xcbutilrenderutil
    xorg.xcbutilwm
    xorg.xkeyboardconfig
    xz
    zlib
  ];

  nixpkgs.config.allowUnfree = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Did you read the comment?

}

