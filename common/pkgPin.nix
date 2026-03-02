let
  pkgVersion = "25.11";
  pkgCommit = "fa56d7d6de78f5a7f997b0ea2bc6efd5868ad9e8";
  pkgHash = "0d8xd2rk1phikz7icawxkbdsg8yc5c71hs5aln0kg9hj73f50kaz";
  unstableCommit = "a82ccc39b39b621151d6732718e3e250109076fa";
  unstableHash = "1664s8ffaa3hcvz4d4hwca2l6xl25j8dvzxwmd2ckcskcncq1zc1";
  pkgSrc = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/${pkgCommit}.tar.gz";
    sha256 = pkgHash;
  };
in {
  inherit pkgSrc;
  home-manager = builtins.fetchTarball
    "https://github.com/nix-community/home-manager/archive/release-25.11.tar.gz";

  unstablePkgs = import (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/${unstableCommit}.tar.gz";
    sha256 = unstableHash;
  }) { config = { allowUnfree = true; }; };

  pkgPin = import pkgSrc {
    config = { allowUnfree = true; };
  };
}
