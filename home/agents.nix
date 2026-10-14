{ pkgs, lib, config, hermes-agent, nixpkgs-cursor, ... }:
let
  # cursor-cli is unfree. This import is per-platform so the same module
  # works for buildcorsair (x86_64-linux) and the Mac (aarch64-darwin).
  cursorPkgs = import nixpkgs-cursor {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnfreePredicate = pkg:
      nixpkgs-cursor.lib.getName pkg == "cursor-cli";
  };

  # Secrets stay outside the Nix store. Create/maintain this file yourself
  # (0600). On buildcorsair it should contain at least:
  #   OLLAMA_API_KEY=...
  #   A2A_PEER_TOKENS=hpminihermes:<token>
  hermesSecretsFile = "${config.home.homeDirectory}/.hermes/secrets.env";
in
{
  imports = [
    hermes-agent.homeManagerModules.default
  ];

  home.packages = [
    cursorPkgs.cursor-cli
  ];

  programs.hermes-agent.enable = true;

  # Always-on messaging/A2A gateway on Linux only (buildcorsair). The Mac
  # keeps the CLI via programs.hermes-agent; enable services there later if
  # wanted. Requires users.users.<name>.linger = true on NixOS.
  services.hermes-agent = lib.mkIf pkgs.stdenv.isLinux {
    enable = true;
    gateway.enable = true;
    # `hermes gateway` needs the `run` subcommand for a foreground ExecStart.
    extraArgs = [ "run" ];

    # Web UI + API on the LAN (auth gate engages for non-loopback binds).
    # Set username/password once with an interactive:
    #   hermes dashboard --host 0.0.0.0 --port 9119 --no-open
    # before/after switch, or the unit fails closed with no provider.
    backend = {
      mode = "dashboard";
      host = "0.0.0.0";
      port = 9119;
    };

    # Non-secret process env → written into ~/.hermes/.env on activation.
    environment = {
      A2A_AGENT_NAME = "buildcorsair";
      A2A_HOST = "0.0.0.0";
      A2A_PORT = "9900";
      A2A_TRUSTED_PEERS = "hpminihermes";
      A2A_PUBLIC_URL = "http://192.168.1.129:9900";
      # Host/Origin clients use when opening the dashboard on the LAN.
      HERMES_DASHBOARD_PUBLIC_URL = "http://192.168.1.129:9119";
    };

    # Secret keys only — path must be a string (not a Nix path literal).
    environmentFiles = [ hermesSecretsFile ];

    # Deep-merged into ~/.hermes/config.yaml; other keys (e.g. model from
    # `hermes model`) are preserved.
    settings = {
      agent.reasoning_effort = "high";
      gateway.platforms.a2a.enabled = true;
    };
  };
}
