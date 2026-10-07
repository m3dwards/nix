{ config, lib, pkgs, ... }:
{
  # System module (not home-manager): Podman needs /etc/containers, the
  # containers runtime stack, and systemd sockets that only NixOS can set up.
  virtualisation.podman = {
    enable = true;
    # `docker` → `podman` alias for muscle memory / scripts that call docker.
    dockerCompat = true;
  };
}
