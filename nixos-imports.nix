{ hostname }:
{ lib, ... }:
let
  username = import ./common/username.nix;
  pins = import ./common/pkgPin.nix;
  inherit (pins)
    home-manager
    unstablePkgs
    pkgPin
    pkgSrc
    ;
  pkgs = pkgPin;
in
{
  imports = [
    (import ./nixos.nix {
      inherit
        hostname
        home-manager
        username
        pkgs
        unstablePkgs
        ;
    })
  ];
  _module.args = {
    inherit
      home-manager
      username
      unstablePkgs
      hostname
      ;
    pkgs = lib.mkForce pkgs;
  };
}
