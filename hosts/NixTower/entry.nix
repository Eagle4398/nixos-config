# entry.nix
{ config, lib, pkgs, ... }:
let
  hostname = "NixTower";
in
{
  imports = [
     (import ../../nixos.nix { inherit hostname config lib pkgs; })
  ];
}
