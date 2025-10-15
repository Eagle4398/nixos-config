# home.nix
{ config, pkgs, lib, unstablePkgs, username, hostname, ... }:
{
  imports = [ ./home-config.nix ];
  _module.args = {
    username = username;
    hostname = hostname;
  };

  fonts.fontconfig.enable = true;
  home.packages = [ pkgs.nerd-fonts.caskaydia-cove pkgs.home-manager ];

  # Set the state version. Use the version you FIRST start managing
  # your config with Home Manager. Update this value cautiously,
  # referring to Home Manager release notes for breaking changes.
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  programs.chromium = {
    enable = true;
    package = unstablePkgs.brave;
    extensions = [
      { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # ublock origin
      { id = "ponfpcnoihfmfllpaingbgckeeldkhle"; } # enhancer for youtube
      { id = "hfjbmagddngcpeloejdejnfgbamkjaeg"; } # Vimium C
      { id = "nngceckbapebfimnlniiiahkandclblb"; } # Bitwarden
      { id = "dahenjhkoodjbpjheillcadbppiidmhp"; } # Google Scholar Reader
    ];
    commandLineArgs = [
      "--disable-features=WebRtcAllowInputVolumeAdjustment"
      "--password-store=basic"
    ];
  };

}

