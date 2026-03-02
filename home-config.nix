# home-config.nix
{
  config,
  pkgs,
  lib,
  ...
}@args:
let
  pins = import ./common/pkgPin.nix;
  inherit (pins) pkgSrc;

  username = if args ? "username" then args.username else import ./common/username.nix;

  hostname = lib.strings.trim (
    if args ? "hostname" then
      args.hostname
    else if (builtins.getEnv "HOSTNAME") != "" then
      builtins.getEnv "HOSTNAME"
    else
      builtins.readFile "/etc/hostname"
  );
  exportAttributes = { };
  pathsToAdd = [ ];
  primaryPath = ./hosts/${hostname}/home-${hostname}.nix;
in
{
  imports = [ ] ++ (if builtins.pathExists primaryPath then [ primaryPath ] else [ ]);
  home.username = username;
  home.homeDirectory = "/home/${username}";

  # Set the state version. Use the version you FIRST start managing
  # your config with Home Manager. Update this value cautiously,
  # referring to Home Manager release notes for breaking changes.
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  home.sessionVariables = exportAttributes // {
    DOTFILES = "${toString ./dotfiles}";
    NIX_PATH = "nixpkgs=${pkgSrc}";
    LIBSQLITE = "${pkgs.sqlite.out}/lib/libsqlite3.so";
    _JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=lcd";
    SSH_AUTH_SOCK = "${config.home.homeDirectory}/.bitwarden-ssh-agent.sock";
    # XDG_MENU_PREFIX = "plasma-";
  };

  home.sessionPath = pathsToAdd ++ [
    "${config.home.homeDirectory}/.local/bin"
    "${config.home.homeDirectory}/.local/bin/scripts"
    "${toString ./dotfiles}/.local/bin/scripts"
  ];

  programs.bash = {
    enable = true;
    shellAliases = {
      la = "ls -A";
      # vim = "nvim -c \"Telescope find_files\"";
    };
    bashrcExtra = ''
      # if secret-tool lookup application ghcr &>/dev/null; then
      #   # export CR_PAT="$(secret-tool lookup application ghcr)"
      #   # echo $(secret-tool lookup application ghcr) | podman login ghcr.io -u eagle4398 --password-stdin
      # fi

      # Auto-start tmux if shell is interactive, not already in tmux, and not in screen
      if [[ $- == *i* ]] && [[ -z "$TMUX" ]] && [[ "$TERM" != "screen" ]] && [[ -z "$container" ]] && [[ ! -f "/.dockerenv" ]]; then
        exec ${pkgs.tmux}/bin/tmux 
      fi

      export EDITOR=$(which nvim)
      export SUDO_EDITOR=$(which nvim)
      export VISUAL=$(which nvim)
    '';
  };

  xdg.configFile."menus/applications.menu".source = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/KDE/plasma-workspace/master/menu/desktop/plasma-applications.menu";
    hash = "sha256-pVvOXRPvpsnhmGEAldOKpOuGJXo2cNSIQidecm5wK/Y=";
  };

  home.file = {
    ".config/alacritty/alacritty-host.toml" = {
      source = ./dotfiles/.config/alacritty/alacritty-${hostname}.toml;
    };
    ".config/alacritty/alacritty.toml" = {
      source = ./dotfiles/.config/alacritty/alacritty.toml;
    };
    ".config/alacritty/alacritty-common.toml" = {
      source = ./dotfiles/.config/alacritty/alacritty-common.toml;
    };
    # ".config/alacritty" = {
    #   source = ./dotfiles/.config/alacritty;
    #   recursive = true;
    # };
    ".screenlayout" = {
      source = config.lib.file.mkOutOfStoreSymlink ./dotfiles/.screenlayout;
    };
    ".config/nixconfig" = {
      source = config.lib.file.mkOutOfStoreSymlink ./dotfiles/..;
    };
    ".config/dotfiles" = {
      source = config.lib.file.mkOutOfStoreSymlink ./dotfiles;
    };
    #  ".config/home-manager/home.nix" = {
    #   source = config.lib.file.mkOutOfStoreSymlink ./home-config.nix;
    #  force = true;
    # };
    ".config/i3" = {
      source = ./dotfiles/.config/i3;
      recursive = true;
    };
    ".local/bin/dotfilelaunch" = {
      source = ./dotfiles/.local/bin/dotfilelaunch;
    };
    ".config/nvim" = {
      # source = ./dotfiles/.config/nvim;
      source = config.lib.file.mkOutOfStoreSymlink ./dotfiles/.config/nvim;
      # force = true;
      # recursive = true;
    };
    ".config/i3blocks" = {
      source = ./dotfiles/.config/i3blocks;
      recursive = true;
    };
    ".tmux.conf" = {
      source = ./dotfiles/.tmux.conf;
    };
    "wallpaper.jpg" = {
      source = config.lib.file.mkOutOfStoreSymlink ./dotfiles/stowignore/wallpaper.jpg;
    };
    ".local/share/bash-completion/completions" = {
      source = ./dotfiles/.local/share/bash-completion/completions;
      recursive = true;
    };
  };

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

}
