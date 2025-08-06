# entry.nix
{ config, lib, pkgs, ... }:
let
  username = import ../../username.nix;
  home-manager = builtins.fetchTarball https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz;
  unstable = import (builtins.fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz") {
    config = { allowUnfree = true; };
  };
  unstablePkgs = unstable;
  hostname = "NixTower";
in
{
  imports =
    [
      ./hardware-configuration.nix
      ./${hostname}.nix 
      ../../configuration.nix
        (import "${home-manager}/nixos")
    ];

  _module.args = {
    username = username;
    unstablePkgs = unstable; 
    hostname = hostname;
  };

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = ".hm.bak";
  home-manager.users.${username} = import ../../home.nix;
  home-manager.extraSpecialArgs = { inherit unstablePkgs username hostname; };

}
