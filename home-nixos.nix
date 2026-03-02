{
  config,
  lib,
  pkgs,
  unstablePkgs,
  hostname,
  ...
}:
let
  imageName = "debian-toolbox-local";
  imageTag = "13";
  debianToolbox = pkgs.dockerTools.pullImage {
    imageName = "quay.io/toolbx-images/debian-toolbox";
    imageDigest = "sha256:4b2cf643aaf4c47e8db1b15e86fcafa52e23d3d3ee27fcf73dbb6db581be4d20";
    sha256 = "sha256-MoNjSyTCgWA5EEeal0pgm0X0Biagp/Gyr71s0p9KgQ4=";
    finalImageName = imageName;
    finalImageTag = imageTag;
  };

  # impureEnvPkg = pkgs.fetchFromGitHub {
  #   owner = "Eagle4398";
  #   repo = "impure-easyexec-nixpkg";
  #   rev = "2f8a9dbc831a49360bf1d3a4aa6f05eb8c5ad3c7";
  #   sha256 = "1vg34gs699p0hh6axgr6fdqclf2sc8sarf10arfqvk8rkm9jykds";
  # };
  # imageFile = pkgs.callPackage "${impureEnvPkg}/default.nix" { };
in
{
  imports = [ ./home.nix ];

  home.sessionVariables =  {
    DISTROBOX_NAME = imageName;
  };
  systemd.user.services.distrobox-impure-env = {
    Unit = {
      Description = "Impure environment container using Distrobox";
      After = [ "default.target" ];
    };
    Service = {
      Type = "simple";
      Environment = [
        # Crucial: Prevent distrobox from trying to pull the local image from a registry
        "DBX_CONTAINER_ALWAYS_PULL=0"
        "DBX_CONTAINER_MANAGER=podman"
      ];
      ExecStartPre = [
        # Load the locally built image into Podman
        (pkgs.writeShellScript "load-impure-env" ''
          ${pkgs.podman}/bin/podman load < ${debianToolbox} 2>/dev/null || true
        '')
      ];
      ExecStart = pkgs.writeShellScript "start-impure-env" ''
        export PATH=${pkgs.distrobox}/bin:${pkgs.podman}/bin:$PATH

        if ! distrobox list | grep -q "${imageName}"; then
          echo ">>> Creating new Distrobox container..."
          
          echo "this is what it resolves to: "
          echo "--image docker.io/library/${imageName}:${imageTag}"
          distrobox create \
            --name ${imageName} \
            --image docker.io/library/${imageName}:${imageTag} \
            --additional-packages "locales libgtk2.0-0 libnss3 libatk-bridge2.0-0 libasound2 libatspi2.0-0 libxt6 libxft2" \
            --yes
        else
          echo ">>> Reusing existing container..."
        fi

        exec distrobox enter ${imageName} --headless -- exit
      '';
      ExecStop = pkgs.writeShellScript "stop-impure-env" ''
        export PATH=${pkgs.distrobox}/bin:${pkgs.podman}/bin:$PATH
        distrobox stop ${imageName} --yes
      '';
      Restart = "on-failure";
    };
  };
  # systemd.user.services.podman-impure-env = {
  #   Unit = {
  #     Description = "Impure environment container";
  #     After = [ "default.target" ];
  #   };
  #   Service = {
  #     Type = "simple";
  #     ExecStartPre = [
  #       (pkgs.writeShellScript "load-impure-env" ''
  #         ${pkgs.podman}/bin/podman load < ${imageFile} 2>/dev/null || true
  #       '')
  #       # ${pkgs.podman}/bin/podman rm -f impure-env 2>/dev/null || true
  #     ];
  #     ExecStart = pkgs.writeShellScript "start-impure-env" ''
  #       xhost +SI:localuser:$USER || true
  #       if ${pkgs.podman}/bin/podman container exists impure-env; then
  #         echo ">>> Reusing existing container..."
  #         ${pkgs.podman}/bin/podman start -a impure-env
  #       else
  #         echo ">>> Creating new container..."
  #         ${pkgs.podman}/bin/podman run \
  #           --name impure-env \
  #           -v "$HOME:$HOME" \
  #           --ipc=host \
  #           --network=host \
  #           -v /tmp/.X11-unix:/tmp/.X11-unix \
  #           -v /nix/var/nix/db:/nix/var/nix/db:ro \
  #           -v /run/current-system:/run/current-system:ro \
  #           -v /etc/profiles/per-user/gloo:/etc/profiles/per-user/gloo:ro \
  #           -v "''${XAUTHORITY:-$HOME/.Xauthority}:/tmp/.Xauthority:ro" \
  #           -v /nix/store:/nix/store:ro \
  #           -e HOME="$HOME" \
  #           -e DISPLAY="$DISPLAY" \
  #           -e XAUTHORITY=/tmp/.Xauthority \
  #           -e QT_X11_NO_MITSHM=1 \
  #           -e _JAVA_AWT_WM_NONREPARENTING=1 \
  #           --userns=keep-id \
  #           impure-env:latest \
  #           sleep infinity
  #       fi
  #     '';
  #     ExecStop = "${pkgs.podman}/bin/podman stop impure-env";
  #     Restart = "on-failure";
  #   };
  #   # No Install.WantedBy — so it does NOT autostart
  # };

}
