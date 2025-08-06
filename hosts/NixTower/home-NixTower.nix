# home-nixos.nix
{ config, pkgs, lib, ... }@args:
let
  username =
    if args ? "username"
    then args.username
    else import ./username.nix;

  hostname = lib.strings.trim (
if args ? "hostname" then
      args.hostname
    else if (builtins.getEnv "HOSTNAME") != "" then
      builtins.getEnv "HOSTNAME"
    else
      builtins.readFile "/etc/hostname");
in
{
  # # Example machine-specific content
  # home.file = {
  #   ".config/alacritty/alacritty-host.toml" = {
  #     source = ../../dotfiles/.config/alacritty/alacritty-${hostname}.toml;
  #   };
  # };
}

