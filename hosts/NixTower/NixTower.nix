{ config, lib, pkgs, ... }:

let
  username = import ./username.nix;
in
{

  # imports =
  #   [
  #     ./configuration.nix
  #   ];

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


  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];
  boot.loader.grub.splashImage = null;
  boot.loader.grub.gfxmodeBios = "1280x720"; 
  boot.loader.grub.gfxmodeEfi = "1280x720"; 
  boot.loader.grub.gfxpayloadBios = "keep";

  networking.hostName = "NixTower"; 

  hardware.graphics = {
    enable = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    open = true;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  services.xserver = {
    # # Disable auto-config to prevent override
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
    displayManager.setupCommands = ''
      ${pkgs.xorg.xrandr}/bin/xrandr --output DP-2 --mode 2560x1440 --rate 143.86
    '';
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
