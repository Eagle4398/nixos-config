{
  hostname,
  home-manager,
  pkgs,
  unstablePkgs,
  username,
}:
{ lib, ... }:
{
  imports = [
    ./hosts/${hostname}/hardware-configuration.nix
    ./hosts/${hostname}/${hostname}.nix
    ./hosts/${hostname}/packages.nix
    ./configuration.nix
    (import "${home-manager}/nixos")
  ];

  nixpkgs.pkgs = pkgs;
  nix.nixPath = [ "nixpkgs=${pkgs.path}" ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = ".hm.bak";
  home-manager.users.${username} = import ./home-nixos.nix;
  home-manager.extraSpecialArgs = {
    unstablePkgs = unstablePkgs;
    pkgs = pkgs;
    username = username;
    hostname = hostname;
  };
}
