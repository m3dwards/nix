{ config, lib, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
    ../../modules/users.nix
    ../../modules/ssh.nix
    ../../modules/guix.nix
    ../../modules/podman.nix
  ];

  networking.hostName = "buildcorsair";

  # Bootloader (systemd-boot / UEFI).
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use the latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Networking is managed by NetworkManager.
  networking.networkmanager.enable = true;

  # Locale / time / keyboard.
  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };
  console.keyMap = "uk";

  # KDE Plasma 6 desktop on X11 with the SDDM display manager.
  services.xserver.enable = true;
  services.xserver.xkb = {
    layout = "gb";
    variant = "";
  };
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Printing.
  services.printing.enable = true;

  # Sound via PipeWire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  programs.firefox.enable = true;

  # Allow all unfree packages on this desktop machine.
  nixpkgs.config.allowUnfree = true;

  # Desktop-specific additions to the shared 'max' user.
  users.users.max = {
    description = "Max";
    extraGroups = [ "networkmanager" ];
    packages = with pkgs; [
      kdePackages.kate
    ];
  };
}
