{
  description = "NixOS + home-manager configuration for buildcorsair and macOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Current cursor-cli. Separate from nixpkgs-unstable so the Guix pin
    # does not move; nixos-26.05 still has the May 2026 CLI.
    nixpkgs-cursor.url = "github:NixOS/nixpkgs/nixos-unstable";
    hermes-agent.url = "github:NousResearch/hermes-agent";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dotfiles = {
      url = "github:m3dwards/dotfiles";
      flake = false;
    };
    nvim = {
      url = "github:m3dwards/nvim";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nixpkgs-cursor, hermes-agent, home-manager, dotfiles, nvim, ... }:
    let
      # nixpkgs for the Mac (standalone home-manager).
      darwinSystem = "aarch64-darwin";
      darwinPkgs = import nixpkgs {
        system = darwinSystem;
      };

      # Guix (from unstable) for the dev shell on Linux.
      linuxSystem = "x86_64-linux";
      linuxPkgs = nixpkgs.legacyPackages.${linuxSystem};
      guixPkgs = import nixpkgs {
        system = linuxSystem;
        overlays = [
          (final: prev: {
            guix = nixpkgs-unstable.legacyPackages.${prev.stdenv.hostPlatform.system}.guix;
          })
        ];
      };
    in {
      nixosConfigurations.buildcorsair = nixpkgs.lib.nixosSystem {
        system = linuxSystem;
        specialArgs = { inherit nixpkgs-unstable; };
        modules = [
          ./machines/buildcorsair/default.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit dotfiles nvim hermes-agent nixpkgs-cursor; };
            home-manager.users.max = {
              imports = [
                ./home/common.nix
                ./home/git.nix
                ./home/bitcoin.nix
                ./home/guix-builds.nix
                ./home/agents.nix
                ./home/linux.nix
              ];
            };
          }
        ];
      };

      homeConfigurations."maxedwards" = home-manager.lib.homeManagerConfiguration {
        pkgs = darwinPkgs;
        extraSpecialArgs = { inherit dotfiles nvim hermes-agent nixpkgs-cursor; };
        modules = [
          ./home/common.nix
          ./home/git.nix
          ./home/bitcoin.nix
          ./home/agents.nix
          ./home/mac.nix
        ];
      };

      devShells.${linuxSystem} = {
        guix = guixPkgs.mkShell {
          packages = with guixPkgs; [
            guix
            git
            fish
          ];
          shellHook = ''
            export PATH="${guixPkgs.guix}/bin:$PATH"
            exec ${guixPkgs.fish}/bin/fish -l
          '';
        };

        # Libraries for a local Bitcoin Core build (`cmake -B build` from
        # ~/source/bitcoin). gcc and cmake are already user packages; this shell
        # puts Boost, libevent, SQLite, and Cap'n Proto on CMake's search path.
        # Matches CMake defaults: wallet and IPC on, GUI and ZMQ off.
        bitcoin = linuxPkgs.mkShell {
          packages = with linuxPkgs; [
            cmake
            pkg-config
            python3
            boost
            libevent
            sqlite
            capnproto
          ];
        };
      };
    };
}
