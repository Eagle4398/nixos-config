{ config, lib, pkgs, hostname, ... }@args:
with lib;
let
  cfg = config.home_custom.packages;

  versionFilePath = ../../hosts/${hostname}/nvidiaVersion.nix;
  hasNvidia = builtins.pathExists versionFilePath;
  hasDualGPU = if builtins.pathExists ../../hosts/${hostname}/dualgpu.nix then
    true
  else
    false;
  nvidiaVersionStr = if hasNvidia then import versionFilePath else null;

  nixGLinput = args.nixgl or null;
  nixGL_local = if nixGLinput != null then
    import "${nixGLinput}/default.nix" {
      inherit pkgs;
      nvidiaVersion = nvidiaVersionStr;
    }
  else
    null;

  nixGLMesa =
    if nixGLinput == null then pkgs.nixGL.nixGLMesa else nixGL_local.nixGLMesa;

  nixGLNvidia = if hasNvidia then
    (if nixGLinput == null then
      pkgs.nixGL.auto.nixGLNvidia
    else
      nixGL_local.nixGLNvidia)
  else
    null;

  # nixGL = import (builtins.fetchTarball {
  #   url =
  #     "https://github.com/nix-community/nixGL/archive/b6105297e6f0cd041670c3e8628394d4ee247ed5.tar.gz";
  #   sha256 = "1zv3bshk0l4hfh1s7s3jzwjxl0nqqcvc4a3kydd3d4lgh7651d3x";
  # }) {
  #   inherit pkgs;
  #   nvidiaVersion = nvidiaVersionStr;
  # };

  # config.lib.nixGL.wrap is supposed to work but doesn't for some reason.

  nvidiaLaunch = if hasNvidia then
    (pkgs.writeShellScriptBin "nixGLNvidiaPrime" ''
      export __NV_PRIME_RENDER_OFFLOAD=1
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export __VK_LAYER_NV_optimus=NVIDIA_only
      # Safe injection of host encoding libs
      # export LD_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

      exec ${nixGLNvidia}/bin/nixGLNvidia-${nvidiaVersionStr} "$@"
    '')
  else
    null;
  nixGLNvidiaWrap = pkg:
    pkgs.symlinkJoin {
      name = "nixGL-${pkg.name}";
      paths = [ pkg ];
      postBuild = ''
              shopt -s nullglob
              for binPath in "$out/bin/"*; do
                binName=$(basename "$binPath")
                
                # Unlink the original symlink
                rm "$binPath"
                
                # Write the wrapper script
                # NOTE: $binName is NOT escaped, so it is interpolated at build time.
                # NOTE: \$@ IS escaped, so it is preserved for run time.
                cat > "$binPath" <<EOF
        #!${pkgs.bash}/bin/bash
        exec ${nvidiaLaunch}/bin/nixGLNvidiaPrime ${pkg}/bin/"$binName" "\$@"
        EOF
                chmod +x "$binPath"
              done
      '';
    };

  nixGLMesaWrap = pkg:
    pkgs.symlinkJoin {
      name = "nixGL-${pkg.name}";
      paths = [ pkg ];
      postBuild = ''
              shopt -s nullglob
              for binPath in "$out/bin/"*; do
                binName=$(basename "$binPath")
                
                rm "$binPath"
                
                cat > "$binPath" <<EOF
        #!${pkgs.bash}/bin/bash
        exec ${nixGLMesa}/bin/nixGLMesa ${pkg}/bin/"$binName" "\$@"
        EOF
                chmod +x "$binPath"
              done
      '';
    };

in {
  options.home_custom.packages = {
    core = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "Core packages (no wrapping)";
    };
    gui = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "GUI packages (wrapped with nixGL if standalone)";
    };
    gui_HWACCELL = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "GUI packages (wrapped with nixGL if standalone)";
    };
    standalone = mkOption {
      type = types.bool;
      default = false;
      description =
        "Whether this is a standalone Home Manager instpallation (requires nixGL)";
    };
  };

  config = {
    home.packages = cfg.core ++ (if cfg.standalone then
      (if hasNvidia && !hasDualGPU then
        (map nixGLNvidiaWrap cfg.gui)
      else
        (map nixGLMesaWrap cfg.gui)) ++ [ nixGLMesa ]
      ++ lib.optional hasNvidia nvidiaLaunch ++ (if hasNvidia then
        (map nixGLNvidiaWrap cfg.gui_HWACCELL)
      else
        (map nixGLMesaWrap cfg.gui_HWACCELL))
    else
      cfg.gui);
  };
}
