# flake.nix
{
  description = "Multi-Host NixOS Flake mit stable und unstable, sowie Home-Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    self.submodules = true;
    # # Manual specification should make this unnecessary:
    home-manager.inputs.nixpkgs.follows = "nixpkgs";  
  };

  outputs = { self, nixpkgs, unstable, home-manager, dotfilesPath,... }:
    let
      system = "x86_64-linux";
      # this is ugly but works for now...
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      unstablePkgs = import unstable {
        inherit system;
        config.allowUnfree = true;
      };
      hmModule = home-manager.nixosModules.home-manager;

      # username = import ./username.nix;
      # dotfilesRepoPath = "/home/" + username + "/nix_dotfiles";
      # dotfilesPath = "/home/gloo/nix_dotfiles";
    in
    {
      nixosConfigurations = {
        # flake option .#NixTower
        NixTower = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/NixTower/hardware-configuration.nix
            ./hosts/NixTower/desktop.nix
            hmModule
            ./configuration.nix
            # # Alternative dazu, dass ich in SpecialArgs override 
            # "${nixpkgs}/nixos/modules/misc/nixpkgs/read-only.nix" # Importiert readOnlyPkgs-Modul
            # { nixpkgs.pkgs = pkgs; } # Setzt pkgs read-only, behält allowUnfree
          ];
          specialArgs = {
            # pkgs = pkgs;
            unstablePkgs = unstablePkgs;
            homeManager = home-manager;
          };
        };
        nixos = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./laptop.nix
            ./hosts/laptop/hardware-configuration.nix
            hmModule
            ./configuration.nix
            # # Alternative dazu, dass ich in SpecialArgs override 
            # "${nixpkgs}/nixos/modules/misc/nixpkgs/read-only.nix" # Importiert readOnlyPkgs-Modul
            # { nixpkgs.pkgs = pkgs; } # Setzt pkgs read-only, behält allowUnfree
          ];
          specialArgs = {
            # pkgs = pkgs;
            unstablePkgs = unstablePkgs;
            homeManager = home-manager;
          };
        };
      };
    };
}
