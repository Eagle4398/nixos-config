# laptop.nix
{ config, lib, pkgs, username, hostname, ... }:
let
  # enableHWAcceleration = true;
  # greeter =
  #   import ../../common/sea-greeter.nix { inherit pkgs enableHWAcceleration; };
  # inherit (greeter) sea-greeter;

  certPath = "/etc/nixos/T-TeleSec_GlobalRoot_Class_2.pem";
  cert = pkgs.fetchurl {
    url =
      "https://www.dropbox.com/scl/fi/apgjup1eji1m4nux4fyjt/T-TeleSec_GlobalRoot_Class_2.pem?rlkey=ezetb7rdzjvqxkc0qic8tyqqx&st=abqzjn8u&dl=1";
    sha256 = "b30989fd9e45c74bf417df74d1da639d1f04d4fd0900be813a2d6a031a56c845";
  };
  myTlpSettings = import ../../modules/core/tlp-settings.nix;

in {
  security.pki.certificateFiles = [ cert ];

  # services.xserver.displayManager.lightdm = {
  #   enable = true;
  #   greeter.name = "sea-greeter";
  #   greeter.package = sea-greeter;
  # };

  systemd.services.power-profile-switch = {
    description = "Switch power profiles based on power supply status";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.bash}/bin/bash ${
          ../../dotfiles/.local/bin/scripts
        }/power-bridge.sh %i";
    };
  };

  services.power-profiles-daemon.enable = false; 
  services.tlp = {
    enable = true;
    settings = myTlpSettings;
  };

  services.udev.extraRules = ''
    ACTION=="change", SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_STATUS}=="Discharging", TAG+="systemd", ENV{SYSTEMD_WANTS}="power-profile-switch@on.service"
    ACTION=="change", SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_STATUS}=="Charging", TAG+="systemd", ENV{SYSTEMD_WANTS}="power-profile-switch@off.service"
  '';

  services.libinput = {
    touchpad = {
      sendEventsMode = "enabled";
      scrollMethod = "twofinger";
      naturalScrolling = true;
      tapping = true;
    };
  };

  services.libinput.enable = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.grub.efiInstallAsRemovable = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "button.lid_init_state=open" "amd_pstate=active" ];

  networking.hostName = hostname;
  services.xserver.exportConfiguration = true;
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  services.blueman.enable = true;
  environment.etc."ssl/certs/T-TeleSec_GlobalRoot_Class_2.pem".source = cert;
  # networking.networkmanager.ensureProfiles.profiles = {
  #   "eduroam" = {
  #     connection = {
  #       id = "eduroam";
  #       type = "wifi";
  #     };
  #     wifi = {
  #       mode = "infrastructure";
  #       ssid = "eduroam";
  #     };
  #     wifi-security = {
  #       key-mgmt = "wpa-eap";
  #     };
  #     "802-1x" = {
  #       eap = "peap";
  #       anonymous-identity = "eduroam@uni-bremen.de";
  #       ca-cert = "/etc/ssl/certs/T-TeleSec_GlobalRoot_Class_2.pem";
  #       domain-suffix-match = "radius.wlan.uni-bremen.de";
  #       phase2-auth = "mschapv2";
  #     };
  #     ipv4.method = "auto";
  #     ipv6 = {
  #       method = "auto";
  #       addr-gen-mode = "stable-privacy";
  #     };
  #   };
  # };
}
