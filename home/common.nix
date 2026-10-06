{ lib, pkgs, dotfiles, nvim, ... }:
{
  home.packages = with pkgs; [
    ripgrep
    fd
    bat
    htop
    direnv
    gnumake
    tmux
    neovim
  ];

  programs.fish = {
    enable = true;
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = false;
  };

  home.file = {
    ".config/fish/conf.d/10-starship.fish".text = ''
      starship init fish | source
    '';
    ".config/fish/functions" = {
      source = "${dotfiles}/fish/.config/fish/functions";
      recursive = true;
    };
    ".config/nvim" = {
      source = nvim;
      recursive = true;
    };
  };

  # Let home-manager manage itself
  programs.home-manager.enable = true;

  home.stateVersion = "26.05";
}
