{ config, lib, pkgs, username, userPackages, nixOSPackages, guiPackages, ... }:

{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "audio" ];
    packages = userPackages ++ nixOSPackages ++ guiPackages;
  };
}
