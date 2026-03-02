{ ... }:
let 
  hostname = "nixos";
in {
  imports = [ 
    # Pass hostname explicitly as a function argument
    (import ../../nixos-imports.nix { inherit hostname; }) 
  ];
}
