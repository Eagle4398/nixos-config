{ config, lib, pkgs, ... }:
let
  # greeter = pkgs.callPackage (/home/gloo/projects/lightdm-webkit-greeter-nixpkg/default.nix) { inherit pkgs; };
  greeter = pkgs.callPackage (pkgs.fetchFromGitHub {
    owner = "Eagle4398";
    repo = "lightdm-webkit-greeter-litarvan-zaynchen";
    rev = "9eb440e3dc526160d606cfa13902a6e0eb5987ab";
    hash = "sha256-Y4ano8FXqzD6j4y0goyFzEkPQtgkqqrD0V2Kic/dXFA=";
  } + /default.nix) { inherit pkgs; };
in {
  nix.settings.http2 = false;

  # services.xserver.displayManager.lightdm = {
  #   enable = true;
  #   # greeter.name = "sea-greeter";
  #   greeter.name = greeter.pname;
  #   greeter.package = greeter.xgreeters;
  # };

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

  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    open = true;

    modesetting.enable = true;
    nvidiaSettings = true;
    powerManagement.enable = false;
  };

  services.picom = {
    enable = true;
    backend = "glx"; # Often smoother than the default "xrender"
    # vSync = true;
  };

  # # attempts to make kde google drive work without plasma but XD!
  # services.gnome.gnome-keyring.enable = true;
  # security.pam.services.lightdm.enableGnomeKeyring = true;
  #
  # environment.sessionVariables = {
  #   # Tells Qt where to look for QML modules (like kaccounts)
  #   QML2_IMPORT_PATH = [
  #     "${pkgs.kdePackages.kaccounts-integration}/lib/qt-6/qml"
  #     "${pkgs.kdePackages.kaccounts-providers}/lib/qt-6/qml"
  #     "${pkgs.kdePackages.kcmutils}/lib/qt-6/qml"
  #   ];
  #
  #   # Tells KDE where to find the actual binary plugins (.so files)
  #   QT_PLUGIN_PATH = [
  #     "${pkgs.kdePackages.kaccounts-integration}/lib/qt-6/plugins"
  #     "${pkgs.kdePackages.kaccounts-providers}/lib/qt-6/plugins"
  #
  #   ];
  #   SIGNON_PLUGIN_PATH = "${pkgs.kdePackages.signond}/lib/signon";
  # };
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
