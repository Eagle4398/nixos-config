{ config, lib, pkgs, username, ... }:

{
  users.users.${username}.packages = [
    # Add host-specific user packages here
  ];

  environment.systemPackages = [
    # Add host-specific system packages here
  ];
}
