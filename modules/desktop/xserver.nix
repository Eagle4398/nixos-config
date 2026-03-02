{
  config,
  lib,
  pkgs,
  ...
}:

{
  services.xserver.enable = true;

  services.xserver.displayManager.setupCommands = ''
    ${pkgs.numlockx}/bin/numlockx on
  '';

  services.xserver.xkb = {
    layout = "us,de";
    variant = "dvorak,";
    # Composes produces euro with (comp)e=
    options = "caps:escape,compose:ralt,grp:win_space_toggle";
  };

  services.xserver.displayManager.lightdm.enable = true;

  services.xserver.xautolock.time = 20;

  # mouse acceleration creates inconsistencies on nvidia hidpi. I also hate it.
  services.libinput = {
    enable = true;
    mouse.accelProfile = "flat";
  };

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.lightdm.enableGnomeKeyring = true;

  services.xserver.displayManager.sessionCommands = ''
    eval $(${pkgs.gnome-keyring}/bin/gnome-keyring-daemon --start --components=pkcs11,secrets)
  '';
}
