{ config, lib, pkgs, unstablePkgs, nixGL, hostname, ... }:
let
  # convert tlp nix settings to tlp file
  myTlpSettings = import ./modules/core/tlp-settings.nix;
  toTlpConfig = attrs:
    lib.concatStringsSep "\n" (lib.mapAttrsToList
      (k: v: "${k}=${if builtins.isString v then ''"${v}"'' else toString v}")
      attrs);
  tlpConfigFile = pkgs.writeText "tlp.conf" (toTlpConfig myTlpSettings);

  userPackages =
    import ./common/userPackages.nix { inherit pkgs unstablePkgs; };
  hmStandalonePackages =
    import ./common/hmStandalonePackages.nix { inherit pkgs unstablePkgs; };
  envPackages = import ./common/envPackages.nix { inherit pkgs unstablePkgs; };
  guiPackages = import ./common/guiPackages.nix { inherit pkgs unstablePkgs; };

in {
  imports = [ ./home.nix ./modules/home/packages.nix ];
  _module.args = {
    # inherit nixGL;
    # inherit unstablePkgs nixGL hostname;
    # pkgs = lib.mkForce pkgs;
  };

  home.file.".config/tlp/generated-tlp.conf".text = toTlpConfig myTlpSettings;

  home_custom.packages = {
    standalone = true;
    core = userPackages ++ envPackages ++ hmStandalonePackages ++ [
      (pkgs.writeShellScriptBin "install-tlp-conf" ''
        echo "Installing TLP config to /etc/tlp.conf (requires sudo)..."
        sudo cp ~/.config/tlp/generated-tlp.conf /etc/tlp.conf
        sudo systemctl restart tlp
        echo "Done."
      '')
    ];
    gui = guiPackages;
  };

  home.file = { ".xsessionrc" = { source = ./dotfiles/.xsessionrc; }; };

}
