# laptop.nix
{ config, lib, pkgs, username, hostname, ... }:
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
        rev = "5ffcbd3a595c82fcef87f02a4ed9509fe62b8db8";
        sha256 = "sha256-W20hbwRqaoRAEHpmFgyL9Q+Wf8neMOQPkWeq/k72mhg=";
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
      enableHWAcceleration = true;
    };

  # username = import ../../username.nix;
  certPath = "/etc/nixos/T-TeleSec_GlobalRoot_Class_2.pem";
  cert = pkgs.fetchurl {
    url = "https://www.dropbox.com/scl/fi/apgjup1eji1m4nux4fyjt/T-TeleSec_GlobalRoot_Class_2.pem?rlkey=ezetb7rdzjvqxkc0qic8tyqqx&st=abqzjn8u&dl=1";
    sha256 = "b30989fd9e45c74bf417df74d1da639d1f04d4fd0900be813a2d6a031a56c845";
  };

  localHashedScript = filepath: hash:
    let
      fetched = pkgs.fetchurl {
        url = "file://${filepath}";
        sha256 = hash;
      };
      filename = baseNameOf filepath;
      nixBash = "${pkgs.bash}/bin/bash";
    in
    pkgs.runCommand "script-exec" { } ''
      cp ${fetched} ./tmpfile
      # Replace any shebang ending with 'bash' with the Nix bash path
      sed -i "1s|^#!.*bash$|#!${nixBash}|" ./tmpfile
      install -Dm755 ./tmpfile $out/bin/${filename}
    '';
  localScript = filepath:
    let
      filename = baseNameOf filepath;
      content = builtins.readFile filepath;
    in
    pkgs.writeScriptBin filename content;

  scriptspath = ../../dotfiles/.local/bin/scripts;
  # powersave = localHashedScript "${scriptspath}/powersave" "sha256-A8YU4YAIKG6JvqXBgKkzj69FYUnddNdbBuDVnToN2CE=";
  powersaveroot = localHashedScript "${scriptspath}/powersaveroot" "sha256-ijGi+/HsD0EBflOHHUGejUV8cUGBAFYlZAlHiPp6psg=";
  setEppHint = localHashedScript "${scriptspath}/set_epp_hint" "sha256-gw5VQ42fA9vJyqoWao6XRjrurO2wQldTgBly9Ws4CwI=";
  changehz = localScript "${scriptspath}/changehz";
  powersaveuser = localScript "${scriptspath}/powersaveuser";

  logger = "${pkgs.util-linux}/bin/logger";

in
{
  imports =
    [
      # ./hardware-configuration.nix
      # ../../configuration.nix
    ];
  security.pki.certificateFiles = [
    cert
  ];

  services.xserver.displayManager.lightdm = {
    enable = true;
    greeter.name = "sea-greeter";
    greeter.package = sea-greeter;
  };

  systemd.user.services.powersave-user = {
    description = "Perform user-level power state actions";
    script = ''
      export PATH=${lib.makeBinPath [
        pkgs.bash         
        pkgs.coreutils    
        pkgs.gnugrep      
        pkgs.gawk         
        pkgs.gnused       
        pkgs.xorg.xrandr  
        powersaveuser     
        changehz          
      ]}:$PATH 
        ${powersaveuser}/bin/powersaveuser on
    '';
  };
  systemd.user.services.performance-user = {
    description = "Perform user-level power state actions";
    script = ''
      export PATH=${lib.makeBinPath [
        pkgs.bash         
        pkgs.coreutils    
        pkgs.gnugrep      
        pkgs.gawk         
        pkgs.gnused       
        pkgs.xorg.xrandr  
        powersaveuser     
        changehz          
      ]}:$PATH 
        ${powersaveuser}/bin/powersaveuser off 
    '';
  };

  systemd.services.performance = {
    description = "Dispatch power state changes to root and user actions";
    path = [
      pkgs.bash
      pkgs.coreutils
      pkgs.gnugrep
      pkgs.util-linux
      pkgs.systemd
      powersaveroot
      setEppHint
    ];
    serviceConfig = {
      Type = "oneshot";
    };
    script = ''
              ${powersaveroot}/bin/powersaveroot off 

            USER_UID=${toString config.users.users.${username}.uid}
            if ${pkgs.systemd}/bin/loginctl list-sessions | ${pkgs.gnugrep}/bin/grep -q "$USER_UID"; then 
      ${pkgs.sudo}/bin/sudo -u ${username} XDG_RUNTIME_DIR=/run/user/1000 ${pkgs.systemd}/bin/systemctl --user start "performance-user.service"
            else
              echo "User '${username}' not logged in, skipping user-level power actions." >&2
            fi
    '';


  };
  systemd.services.powersave = {
    description = "Dispatch power state changes to root and user actions";
    path = [
      pkgs.bash
      pkgs.coreutils
      pkgs.gnugrep
      pkgs.util-linux
      pkgs.systemd
      powersaveroot
      setEppHint
    ];
    serviceConfig = {
      Type = "oneshot";
    };
    script = ''
              ${powersaveroot}/bin/powersaveroot on 

            USER_UID=${toString config.users.users.${username}.uid}
            if ${pkgs.systemd}/bin/loginctl list-sessions | ${pkgs.gnugrep}/bin/grep -q "$USER_UID"; then 
      ${pkgs.sudo}/bin/sudo -u ${username} XDG_RUNTIME_DIR=/run/user/1000 ${pkgs.systemd}/bin/systemctl --user start "powersave-user.service"
            else
              echo "User '${username}' not logged in, skipping user-level power actions." >&2
            fi
    '';


  };

  services.udev.extraRules = ''
    ACTION=="change", SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_STATUS}=="Discharging", TAG+="systemd", ENV{SYSTEMD_WANTS}="powersave.service"
    ACTION=="change", SUBSYSTEM=="power_supply", ENV{POWER_SUPPLY_STATUS}=="Charging", TAG+="systemd", ENV{SYSTEMD_WANTS}="performance.service"
  '';

  services.libinput = {
    touchpad = {
      sendEventsMode = "enabled";
      scrollMethod = "twofinger";
      naturalScrolling = true;
      tapping = true;
    };
  };

  # TODO
  # https://github.com/NixOS/nixos-hardware/tree/master/lenovo/ideapad/15ach6
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
