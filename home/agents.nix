{ pkgs, hermes-agent, nixpkgs-cursor, ... }:
let
  # cursor-cli is unfree. This import is per-platform so the same module
  # works for buildcorsair (x86_64-linux) and the Mac (aarch64-darwin).
  cursorPkgs = import nixpkgs-cursor {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnfreePredicate = pkg:
      nixpkgs-cursor.lib.getName pkg == "cursor-cli";
  };
in
{
  imports = [
    hermes-agent.homeManagerModules.default
  ];

  home.packages = [
    cursorPkgs.cursor-cli
  ];

  # CLI only (`hermes` on PATH, state in ~/.hermes). The messaging gateway
  # stays off; enable services.hermes-agent once a provider key is available.
  programs.hermes-agent.enable = true;
}
