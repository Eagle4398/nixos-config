{ config, lib, ... }:
let
  pins = import ./common/pkgPin.nix;
  inherit (pins) unstablePkgs pkgPin pkgSrc;
  # pkgs = pkgPin;

  hostname = lib.strings.trim (if (builtins.getEnv "HOSTNAME") != "" then
    builtins.getEnv "HOSTNAME"
  else
    builtins.readFile "/etc/hostname");

  versionFilePath = ../../hosts/${hostname}/nvidiaVersion.nix;
  hasNvidia = builtins.pathExists versionFilePath;
  nvidiaVersionStr = if hasNvidia then import versionFilePath else null;

  nixGLOverlay = self: super: {
    nixGL = import (builtins.fetchTarball {
      url =
        "https://github.com/nix-community/nixGL/archive/b6105297e6f0cd041670c3e8628394d4ee247ed5.tar.gz";
      sha256 = "1zv3bshk0l4hfh1s7s3jzwjxl0nqqcvc4a3kydd3d4lgh7651d3x";
    }) {
      pkgs = self;
      nvidiaVersion = nvidiaVersionStr;
    };
  };

  pkgs = import pkgSrc {
    overlays = [ nixGLOverlay ];
    config = { allowUnfree = true; };
  };

in {
  imports = [ ./home-standalone.nix ];
  _module.args = {
    inherit unstablePkgs hostname;
    pkgs = lib.mkForce pkgs;
  };

}
