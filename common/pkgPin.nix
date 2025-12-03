let
  pkgCommit = "6c8f0cca84510cc79e09ea99a299c9bc17d03cb6";
  pkgHash = "0ak7hm6x92ih1fxa0kxqj065p7vqkkcw3cfkhla8x979ac88b5ik";
  unstableCommit = "2d293cbfa5a793b4c50d17c05ef9e385b90edf6c";
  unstableHash = "03n6v687rkbjriah1bn9m8ysc1bq5b0y82lmy01352j7i17yx7d6";
in {
  home-manager = builtins.fetchTarball
    "https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz";

  unstablePkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/${unstableCommit}.tar.gz";
    sha256 = unstableHash; 
  }) { config = { allowUnfree = true; }; };
  pkgPin = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/${pkgCommit}.tar.gz";
    sha256 = pkgHash;
  }) { config = { allowUnfree = true; }; };

  # unstablePkgs = import (builtins.fetchTarball {
  #   url = "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz";
  #   sha256 = "03n6v687rkbjriah1bn9m8ysc1bq5b0y82lmy01352j7i17yx7d6";
  # }) { config = { allowUnfree = true; }; };
  #
  # pkgPin = import (builtins.fetchTarball {
  #   url = "https://github.com/NixOS/nixpkgs/archive/nixos-25.05.tar.gz";
  #   sha256 = "0ak7hm6x92ih1fxa0kxqj065p7vqkkcw3cfkhla8x979ac88b5ik";
  # }) { config = { allowUnfree = true; }; };
}
