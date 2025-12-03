# nixos.nix
{ config, lib, pkgs, hostname, ... }:
let
  username1 = import ./common/username.nix;
  pins = import ./common/pkgPin.nix;
  inherit (pins) home-manager unstablePkgs pkgPin;
  # unstablePkgs = unstable;
  hostname = "NixTower";
  username = username1;
in {
  imports = [
    ./hosts/${hostname}/hardware-configuration.nix 
    ./hosts/${hostname}/NixTower.nix 
    ./configuration.nix
    (import "${home-manager}/nixos")
  ];

  _module.args = {
    username = username1;
    unstablePkgs = unstablePkgs;
    hostname = hostname;
  };

  nixpkgs.pkgs = pkgPin;

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = ".hm.bak";
  home-manager.users.${username} = import ./home.nix;
  home-manager.extraSpecialArgs = {
    unstablePkgs = unstablePkgs;
    username = username;   
    hostname = hostname;
  };
}
