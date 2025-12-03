{ config, pkgs, lib, ... }:
let
  pins = import ./common/pkgPin.nix;
  inherit (pins) unstablePkgs pkgPin;
  pkgs = pkgPin;

  nixGL = import (builtins.fetchTarball {
    url = "https://github.com/nix-community/nixGL/archive/master.tar.gz";
    sha256 = "1zv3bshk0l4hfh1s7s3jzwjxl0nqqcvc4a3kydd3d4lgh7651d3x";
  }) { inherit pkgs; };

  nixGLWrap = pkg:
    pkgs.buildEnv {
      name = "nixGL-${pkg.name}";
      paths = [ pkg ] ++ (map (bin:
        pkgs.hiPrio (pkgs.writeShellScriptBin bin ''
          exec ${nixGL.auto.nixGLDefault}/bin/nixGL ${pkg}/bin/${bin} "$@"
        '')) (builtins.attrNames (builtins.readDir "${pkg}/bin")));
    };

  userPackages =
    import ./common/userPackages.nix { inherit pkgs unstablePkgs; };
  hmStandalonePackages =
    import ./common/hmStandalonePackages.nix { inherit pkgs unstablePkgs; };
  envPackages = import ./common/envPackages.nix { inherit pkgs unstablePkgs; };
  guiPackages = import ./common/guiPackages.nix { inherit pkgs unstablePkgs; };
in {
  imports = [ ./home.nix ];
  _module.args = { unstablePkgs = unstablePkgs; };

  home.packages = userPackages ++ envPackages ++ hmStandalonePackages
    ++ [ nixGL.auto.nixGLDefault ] ++ (map nixGLWrap guiPackages);
  # ++ [ nixGL.auto.nixGLDefault ] ++ (map config.lib.nixGL.wrap guiPackages);
  # # ^ is supposed to work but doesn't.

  home.file = { ".xsessionrc" = { source = ./dotfiles/.xsessionrc; }; };

  # home.sessionVariables = {
  #   ALSA_PLUGIN_DIRS = "${pkgs.alsa-plugins}/lib/alsa-lib";
  # };

  # nix.package = pkgs.nix;
  # # not necessary with manual package pin 
  # nixpkgs.config = {
  #   allowUnfree = true;
  #   allowUnfreePredicate = (_: true);
  # };

}
