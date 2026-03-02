{ config, lib, ... }:

{
  networking.networkmanager.enable = true;
  networking.firewall.allowedTCPPorts = [ 5000 ];
  
  # Reduce boottime by not waiting for network?
  systemd.services.NetworkManager-wait-online.enable = false;
}
