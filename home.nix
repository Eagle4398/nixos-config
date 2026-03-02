# home.nix
{ config, pkgs, lib, unstablePkgs, username, hostname, ... }: {
  imports = [ 
    ./home-config.nix 
  ];
  _module.args = {
    username = username;
    # hostname = hostname;
  };

  fonts.fontconfig.enable = true;
  home.packages = [ pkgs.nerd-fonts.caskaydia-cove ];

  # Set the state version. Use the version you FIRST start managing
  # your config with Home Manager. Update this value cautiously,
  # referring to Home Manager release notes for breaking chanfor ges.
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  programs.brave = {
    enable = true;
    package = unstablePkgs.brave;
    extensions = [
      { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # ublock origin
      { id = "ponfpcnoihfmfllpaingbgckeeldkhle"; } # enhancer for youtube
      { id = "hfjbmagddngcpeloejdejnfgbamkjaeg"; } # Vimium C
      { id = "nngceckbapebfimnlniiiahkandclblb"; } # Bitwarden
      { id = "dahenjhkoodjbpjheillcadbppiidmhp"; } # Google Scholar Reader
      { id = "phmcfcbljjdlomoipaffekhgfnpndbef"; } # Hide Youtube thumbnails
      { id = "khncfooichmfjbepaaaebmommgaepoid"; } # unhook from youtube
      { id = "enamippconapkdmgfgjchkhakpfinmaj"; } # DeArrow
    ];
    commandLineArgs = [
      "--disable-features=WebRtcAllowInputVolumeAdjustment"
      "--disable-features=PasswordManagerOnboarding"
      "--disable-features=AutofillEnableAccountWalletStorage"
      "--password-store=basic" # this creates an odd interactionts with kwallet
# even if you don't have it installed because a dependency with it 
      # is preinstalled with dolphin file manager
    ];
  };

}

