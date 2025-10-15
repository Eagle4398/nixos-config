{ config, pkgs, lib, ... }:
let
  unstablePkgs = import (builtins.fetchTarball
    "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz") {
      config = { allowUnfree = true; };
    };
  userPackages = import ./userPackages.nix { inherit pkgs unstablePkgs; };
  envPackages = import ./envPackages.nix { inherit pkgs unstablePkgs; };
in {
  imports = [ ./home.nix ];
  _module.args = { unstablePkgs = unstablePkgs; };

  home.packages = userPackages ++ envPackages;

}
