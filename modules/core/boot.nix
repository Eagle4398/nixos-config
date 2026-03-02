{ config, lib, pkgs, ... }:

{
  # Windows drives
  boot.supportedFilesystems = [ "ntfs" ];

  boot.initrd.systemd.enable = false;
  # Numlock on by default
  boot.initrd.preLVMCommands = ''
    ${pkgs.kbd}/bin/setleds +num
  '';

  # ssh sometimes causes issues over ipv6
  boot.kernelParams = lib.mkAfter [ "ipv6.disable=1" ];
}
