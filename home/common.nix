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
    # Neovim language tooling lives here rather than in Mason: Mason's installers
    # need npm/go/unzip on PATH and then drop prebuilt binaries outside the store.
    # unzip stays for the few tools Mason still fetches itself (codelldb).
    stylua
    markdownlint-cli2
    clang-tools
    pyright
    unzip
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
    # clangd parses with the compiler's flags from a checkout's
    # compile_commands.json; these two are gcc-only and clang logs each one on
    # every parse. Global rather than a .clangd per checkout, which would be an
    # untracked file in every worktree.
    ".config/clangd/config.yaml".text = ''
      CompileFlags:
        Remove: [-fno-extended-identifiers, -fstack-reuse=none]
    '';
  };

  # Let home-manager manage itself
  programs.home-manager.enable = true;

  home.stateVersion = "26.05";
}
