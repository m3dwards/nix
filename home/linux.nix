{ config, lib, pkgs, ... }:
{
  home.username = "max";
  home.homeDirectory = "/home/max";

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
}
