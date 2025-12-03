{ ... }: {
  nix.settings = {
    substituters = [
      "http://192.168.8.9:5000"
      "https://cache.nixos.org/"
      "https://cuda-maintainers.cachix.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "my-laptop-cache:g3+NoJuKH6X9EFmD7KHHNudfIAt6SXxMDlcMRr+bG4s="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
}
