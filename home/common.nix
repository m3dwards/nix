{ lib, pkgs, dotfiles, nvim, ... }:
{
  home.packages = with pkgs; [
    ripgrep
    fd
    bat
    htop
    direnv
    gnumake
    cmake
    gcc
    tree-sitter
    neovim
    python3
    awscli2
  ];

  programs.tmux = {
    enable = true;
    extraConfig = ''
      set -g mouse on
      # `on`, not the default `external`: external still lets tmux set the outer
      # clipboard itself, but drops OSC 52 coming from applications — which is
      # how nvim reaches the Mac clipboard over ssh.
      set -g set-clipboard on
    '';
  };

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
