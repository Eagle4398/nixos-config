{ config, lib, pkgs, ... }:

{
  home_custom.packages.gui_HWACCELL =
    [ (pkgs.obs-studio.override { cudaSupport = true; }) ];

  home_custom.packages.core = [ ];

  home.sessionVariables = {
    NIX_SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
  };
}
