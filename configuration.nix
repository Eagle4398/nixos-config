{
  config,
  lib,
  pkgs,
  username,
  unstablePkgs,
  ...
}:

let
  userPackages = import ./common/userPackages.nix { inherit pkgs unstablePkgs; };
  envPackages = import ./common/envPackages.nix { inherit pkgs unstablePkgs; };
  nixOSPackages = import ./common/nixOSPackages.nix { inherit pkgs unstablePkgs; };
  guiPackages = import ./common/guiPackages.nix { inherit pkgs unstablePkgs; };
in
{
  imports = [
    ./common/substituters.nix
    ./modules
  ];

  modules = {
    desktop = {
      greeter.enable = true;
    };
    core = {
      nix-ld.enable = true;
      printing.enable = true;
      audio.enable = true;
      gaming.enable = true; # OBS with CUDA
    };
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.trusted-users = [
    "root"
    "gloo"
  ];

  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "de_DE.UTF-8";

  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };


documentation.nixos.enable = false;

  services.udisks2.enable = true;
  services.gvfs.enable = true;
  services.spice-vdagentd.enable = true;

  programs.firefox.enable = true;

  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true; # lets you use `docker` CLI alias
    };
    # oci-containers = {
    #   backend = "podman";
    #   containers.impure-env = {
    #     imageFile = pkgs.callPackage (
    #       pkgs.fetchFromGitHub {
    #         owner = "Eagle4398";
    #         repo = "impure-easyexec-nixpkg";
    #         rev = "70d360d9d17c40a87533c8809e9565d234984397";
    #         sha256 = "sha256:0c5pbk1n0is9d00g2jfykwd4pw2wcb84n0q865vr8xal81a98a0y";
    #       }
    #       + /default.nix
    #     ) { inherit pkgs; };
    #     image = "impure-env:latest";
    #     autoStart = false;
    #     cmd = [
    #       "sleep"
    #       "infinity"
    #     ];
    #     volumes = [
    #       "/home/gloo:/home/gloo"
    #       "/tmp/.X11-unix:/tmp/.X11-unix"
    #     ];
    #     environment = {
    #       HOME = "/home/gloo";
    #       DISPLAY = ":0";
    #     };
    #     extraOptions = [ "--userns=keep-id" ];
    #   };
    # };
  };

  environment.systemPackages = envPackages;

  # Pass packages to the users module via _module.args or inherit
  _module.args = {
    inherit userPackages nixOSPackages guiPackages;
  };

  system.stateVersion = "24.11";
}
