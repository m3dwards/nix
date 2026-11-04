{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    wget
    curl
    git
    fish
    gnupg
    pinentry-curses #allows gpg to ask passphrase
  ];

  programs.fish.enable = true;

  security.sudo.wheelNeedsPassword = false;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Unattended security updates: each night bump the nixpkgs input and rebuild
  # the working tree, then reboot if the new generation changes the kernel
  # (the module does `nixos-rebuild boot` and compares booted vs built).
  system.autoUpgrade = {
    enable = true;
    flake = "/home/max/source/nix#buildcorsair";
    flags = [ "--update-input" "nixpkgs" ];
    dates = "05:00";
    randomizedDelaySec = "45min";
    persistent = true; # catch up after the box was off at 05:00
    allowReboot = true;
    rebootWindow = {
      lower = "05:00";
      upper = "07:00";
    };
  };

  # The upgrade job runs as root, so --update-input would leave flake.lock
  # owned by root and break max's own `nix flake update`. ExecStopPost runs on
  # failure too, so a failed build cannot leave the lock unowned.
  systemd.services.nixos-upgrade.serviceConfig.ExecStopPost = [
    "-${pkgs.coreutils}/bin/chown max:users /home/max/source/nix/flake.lock"
  ];

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "26.05";
}
