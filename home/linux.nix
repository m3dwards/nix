{ config, lib, pkgs, ... }:
{
  home.username = "max";
  home.homeDirectory = "/home/max";

  home.packages = with pkgs; [ gh ];

  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry-curses;
  };

  home.file.".config/fish/conf.d/20-gpg-agent.fish".text = ''
    if status is-interactive
      set -gx GPG_TTY (tty)
      gpg-connect-agent updatestartuptty /bye >/dev/null
    end
  '';

  home.file.".config/fish/conf.d/99-rebuild.fish".text = ''
    alias rebuild "sudo nixos-rebuild switch --flake /home/max/source/nix#buildcorsair"
  '';

  # Absolute flake paths so these work from ~/source/bitcoin, not only from
  # this repo. The Guix shell's hook already execs fish; the Bitcoin shell
  # does not, so the alias starts fish itself.
  home.file.".config/fish/conf.d/30-devshells.fish".text = ''
    alias bitcoin-shell "nix develop /home/max/source/nix#bitcoin -c fish"
    alias guix-shell "nix develop /home/max/source/nix#guix"
  '';
}
