# home-config.nix
{ config, pkgs, lib, ... }@args:
let
  username =
    if args ? "username" then args.username else import ./common/username.nix;

  hostname = lib.strings.trim (if args ? "hostname" then
    args.hostname
  else if (builtins.getEnv "HOSTNAME") != "" then
    builtins.getEnv "HOSTNAME"
  else
    builtins.readFile "/etc/hostname");

  # Nix Enthusiasts will hang me for this but I want my config to be cross-
  # distro compatible. Therefore I have exported my environment variables
  # and paths that I use on other platforms to files which I parse here to be 
  # able to use them in Nix.
  readLinesFromFile = path:
    let
      raw = builtins.readFile path;
      lines = lib.strings.splitString "\n" raw;
      filteredLines = lib.lists.filter (line:
        let trimmed = lib.strings.trim line;
        in trimmed != "" && !(lib.strings.hasPrefix "#" trimmed)) lines;
    in lib.lists.map (line: lib.strings.trim line) filteredLines;

  # This is for parsing "export SSH_AUTH_SOCK=..." etc
  regex =
    "^[[:space:]]*(export[[:space:]]+)?([a-zA-Z_][a-zA-Z0-9_]*)[[:space:]]*=[[:space:]]*(.*)$";
  parseKeyValueLines = lines:
    lib.lists.foldl' (acc: line:
      let match = builtins.match regex line;
      in if match == null then
        acc
      else
        let
          name = lib.lists.elemAt match 1; # Was 0
          rawValue = lib.lists.elemAt match 2; # Was 1
          value = lib.strings.replaceStrings [ "$HOME" ]
            [ "${config.home.homeDirectory}" ] rawValue;
        in if lib.hasAttr name acc then
          abort "Duplicate variable name found in exports file: ${name}"
        else
          acc // { "${name}" = value; }) { } lines;

  # Locations in Submodule dotfiles 
  pathToPathsFile = ./dotfiles/stowignore/path.txt;
  pathToExportsFile = ./dotfiles/stowignore/exports.txt;

  # Resolving $HOME and $BASHRC to nix in paths
  pathLines = readLinesFromFile pathToPathsFile;
  pathsToAdd = lib.lists.map (path:
    lib.strings.replaceStrings [ "$HOME" "$BASHRC" ] [
      "${config.home.homeDirectory}"
      "${toString ./dotfiles}"
    ] path) pathLines;

  exportLines = readLinesFromFile pathToExportsFile;
  exportAttributes = parseKeyValueLines exportLines;

  primaryPath = ./hosts/${hostname}/home-${hostname}.nix;
in {
  # imports = []
  # ++(if builtins.pathExists primaryPath then
  #     [ primaryPath ]
  #       else
  #     [ ]);
  home.username = username;
  home.homeDirectory = "/home/${username}";

  # Set the state version. Use the version you FIRST start managing
  # your config with Home Manager. Update this value cautiously,
  # referring to Home Manager release notes for breaking changes.
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  # # On Other Linux Systems I would resolve $DOTFILES using a truepath wrapper,
  # # that I statically link (mainly because of non-interactive shells) but that is
  # # not necessary on Nix, because it appears that that "non-interactive" like tmux new-shell
  # # still inherits $DOTFILES on nix
  home.sessionVariables = exportAttributes // {
    DOTFILES = "${toString ./dotfiles}";
  };
  home.sessionPath = pathsToAdd;

  programs.bash = {
    enable = true;
    shellAliases = { la = "ls -A"; };
    bashrcExtra = ''
      # Auto-start tmux if shell is interactive, not already in tmux, and not in screen
      if [[ $- == *i* ]] && [[ -z "$TMUX" ]] && [[ "$TERM" != "screen" ]]; then
        exec tmux
      fi
      export SUDO_EDITOR=$(which nvim)
      export VISUAL=$(which nvim)i
    '';
  };

  home.file = {
    ".config/alacritty/alacritty-host.toml" = {
      source = ./dotfiles/.config/alacritty/alacritty-${hostname}.toml;
    };
    ".screenlayout" = {
      source = config.lib.file.mkOutOfStoreSymlink ./dotfiles/.screenlayout;
    };
    ".config/tmux-sessionizer/dotfiles" = {
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
    ".config/alacritty" = {
      source = ./dotfiles/.config/alacritty;
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
    ".tmux.conf" = { source = ./dotfiles/.tmux.conf; };
    ".wallpaper.jpg" = { source = ./dotfiles/.wallpaper.jpg; };
  };

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

}

