{
  description = "Universal Repo for NixOS and Home Manager";

  inputs = {
    nixpkgs.url =
      "github:NixOS/nixpkgs/c97c47f2bac4fa59e2cbdeba289686ae615f8ed4";

    nixpkgs-unstable.url =
      "github:NixOS/nixpkgs/cb369ef2efd432b3cdf8622b0ffc0a97a02f3137";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    username = "gloo";

  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, nixgl, username
    , ... }@inputs:
    let
      mkPkgs = system:
        import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      mkUnstable = system:
        import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
    in {

      nixosConfigurations = let
        hosts = {
          "nixos" = "x86_64-linux";
          "NixTower" = "x86_64-linux";
        };

        mkHost = hostname: system:
          nixpkgs.lib.nixosSystem {
            pkgs = mkPkgs system;
            inherit system;
            specialArgs = {
              inherit inputs;
              unstablePkgs = mkUnstable system;
            };
            modules = [ ./nixos.nix ];
          };
      in nixpkgs.lib.mapAttrs mkHost hosts;

      homeConfigurations = let
        standaloneHosts = { "debianIdeapad" = "x86_64-linux"; };

        mkStandalone = hostname: system:
          home-manager.lib.homeManagerConfiguration {
            pkgs = mkPkgs system;

            extraSpecialArgs = {
              inherit inputs nixgl;
              inherit hostname;
              unstablePkgs = mkUnstable system;
            };

            modules = [ ./home-standalone.nix ];
          };
      in nixpkgs.lib.mapAttrs mkStandalone standaloneHosts;
    };
}
