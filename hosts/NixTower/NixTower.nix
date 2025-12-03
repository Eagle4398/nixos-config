{ config, lib, pkgs, ... }:
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
  litarvan-theme = pkgs.callPackage
    (pkgs.fetchFromGitHub
      {
        owner = "Eagle4398";
        repo = "sea-greeter-lightdm-webkit-theme-litarvan-nixpkg";
        rev = "6b4c0b0e96d39d02a689b35af986194933e4459d";
        sha256 = "sha256-y8PsEKDQeF+jAKFPZGdzrrzoUJXqonYQA7RV5CYKD8w=";
      } + /litarvan-theme.nix)
    { };
  sea-greeter = pkgs.callPackage
    (pkgs.fetchFromGitHub
      {
        owner = "Eagle4398";
        repo = "sea-greeter-lightdm-webkit-theme-litarvan-nixpkg";
        rev = "ce435d6a3103c269275b7f0e2754dd94c2d3378b";
        sha256 = "sha256-2JKyHtkz7VMw7WYVdOO91z9QNzi0iVowF7fsuzFlqDc=";
      } + /sea-greeter.nix)
    {
      theme = litarvan-theme;
      backgrounds = nature-backgrounds;
    };
in
{
    nix.settings.http2 = false;

  services.xserver.displayManager.lightdm = {
    enable = true;
    greeter.name = "sea-greeter";
    greeter.package = sea-greeter;
  };

  # Tower Setup
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.useOSProber = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.loader.grub.extraEntries = ''
    menuentry "Windows" --class windows {
    savedefault
    insmod part_gpt
    insmod fat
    search --no-floppy --fs-uuid --set=root E4A4-3D66 
    chainloader /EFI/Microsoft/Boot/bootmgfw.efi
    }
  '';
  boot.loader.grub.default = "saved";

  boot.initrd.availableKernelModules =
    [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];
  boot.loader.grub.splashImage = null;
  boot.loader.grub.gfxmodeBios = "1280x720";
  boot.loader.grub.gfxmodeEfi = "1280x720";
  boot.loader.grub.gfxpayloadBios = "keep";

  networking.hostName = "NixTower";

  hardware.graphics = { enable = true; };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;

    powerManagement.enable = false;

    powerManagement.finegrained = false;

    open = true;

    nvidiaSettings = true;

    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  services.xserver = {
    # autoConfig = false;

    # Monitor configuration
    monitorSection = ''
      Option "DP-2" "DisplayPort-2"
      Option "PreferredMode" "2560x1440_143.86"
    '';

    # Screen configuration (NVIDIA-specific)
    screenSection = ''
      Option "metamodes" "DP-2: 2560x1440_143.86 +0+0"
      Option "AllowIndirectGLXProtocol" "off"
      Option "TripleBuffer" "on"
    '';

    # Device configuration for NVIDIA
    deviceSection = ''
      Driver "nvidia"
      Option "HardDPMS" "true"
    '';

    # Fallback: Run xrandr command at login
    # displayManager.setupCommands = ''
    #   ${pkgs.xorg.xrandr}/bin/xrandr --output DP-2 --mode 2560x1440 --rate 143.86
    # '';
  };

  # VirtualBox Setup
  # services.xserver.videoDrivers = lib.mkForce [ "vmware" "virtualbox" "modesetting" ];
  #
  # systemd.user.services =
  #   let
  #     vbox-client = desc: flags: {
  #       description = "VirtualBox Guest: ${desc}";
  #
  #       wantedBy = [ "graphical-session.target" ];
  #       requires = [ "dev-vboxguest.device" ];
  #       after = [ "dev-vboxguest.device" ];
  #
  #       unitConfig.ConditionVirtualization = "oracle";
  #
  #       serviceConfig.ExecStart = "${config.boot.kernelPackages.virtualboxGuestAdditions}/bin/VBoxClient -fv ${flags}";
  #     };
  #   in
  #   {
  #     virtualbox-resize = vbox-client "Resize" "--vmsvga";
  #     virtualbox-clipboard = vbox-client "Clipboard" "--clipboard";
  #   };
  #
  # virtualisation.virtualbox.guest = {
  #   enable = true;
  # };
}
