{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.modules;

  greeter = pkgs.callPackage (
    pkgs.fetchFromGitHub {
      owner = "Eagle4398";
      repo = "lightdm-webkit-greeter-litarvan-zaynchen";
      rev = "9eb440e3dc526160d606cfa13902a6e0eb5987ab";
      hash = "sha256-Y4ano8FXqzD6j4y0goyFzEkPQtgkqqrD0V2Kic/dXFA=";
    }
    + /default.nix
  ) { inherit pkgs; };
in
{
  options.modules = {
    desktop = {
      greeter.enable = mkEnableOption "enable litarvan greeter";
    };
    core = {
      nix-ld.enable = mkEnableOption "nix-ld for unpatched binaries";
      printing.enable = mkEnableOption "printing support";
      audio.enable = mkEnableOption "audio support (pulseaudio)";
      gaming.enable = mkEnableOption "gaming related tweaks (OBS with CUDA)";
    };
    misc = {
      java.enable = mkEnableOption "setup java as wished";

    };
  };

  imports = [
    ./core/boot.nix
    ./core/networking.nix
    ./core/users.nix
    ./core/nix-ld.nix
    ./desktop/xserver.nix
    ./desktop/i3.nix
  ];

  config = mkMerge [
    (mkIf cfg.desktop.greeter.enable {
      services.xserver.displayManager.lightdm = {
        greeter.name = greeter.pname;
        greeter.package = greeter.xgreeters;
      };
    })

    (mkIf cfg.core.printing.enable {
      services.printing.enable = true;
    })

    (mkIf cfg.misc.java.enable {
      programs.java = {
        enable = true;
        package = pkgs.jdk21;
      };
    })

    (mkIf cfg.core.audio.enable {
      services.pulseaudio.enable = true;
      services.pulseaudio.support32Bit = true;
      services.pipewire.enable = false;
    })

    (mkIf cfg.core.gaming.enable {
      programs.obs-studio = {
        enable = true;
        package = pkgs.obs-studio.override { cudaSupport = true; };
      };
    })
  ];
}
