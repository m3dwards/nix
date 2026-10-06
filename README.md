# Nix Configuration

A single flake with reusable modules shared across machines:

- **buildcorsair** — a bare-metal NixOS build server (`x86_64-linux`) that also
  performs Bitcoin Guix builds.
- **macOS** — a standalone [home-manager](https://github.com/nix-community/home-manager)
  configuration (`aarch64-darwin`, user `maxedwards`).

## Layout

```
flake.nix                  # outputs for buildcorsair, the Mac, and the guix devShell
machines/
  buildcorsair/            # bare-metal NixOS host (imports modules/*)
modules/                   # shared NixOS system modules (Linux only)
  common.nix               # nix/flakes settings, base packages, git, sudo
  users.nix                # user 'max' + ssh keys
  ssh.nix                  # openssh server (port 22, password auth, LAN only)
  guix.nix                 # services.guix + guix overlay
home/                      # shared home-manager modules
  common.nix               # cross-platform: fish, starship, tools, nvim, dotfiles
  bitcoin.nix              # Bitcoin dev repo bootstrap (both machines)
  agents.nix               # Cursor Agent CLI + Hermes Agent CLI (both machines)
  guix-builds.nix          # Guix build/signing repos + env (buildcorsair only)
  linux.nix / mac.nix      # per-platform username, home dir, rebuild alias
```

Change shared home-manager or Bitcoin config once in `home/*` and both machines
inherit it. NixOS system modules in `modules/*` are shared between NixOS
machines (the Mac uses standalone home-manager and does not consume them).

## buildcorsair (NixOS)

### Install NixOS

Install NixOS on the machine using the [official guide](https://nixos.org/manual/nixos/stable/#sec-installation).

### Add an SSH key

Create a new SSH keypair and add it to GitHub:

```bash
ssh-keygen -t ed25519 -C "youremail@gmail.com"
```

### Clone this repo

```bash
nix-shell -p git --command "git clone https://github.com/m3dwards/nix.git ~/source/nix"
cd ~/source/nix
```

### Hardware configuration

`machines/buildcorsair/hardware-configuration.nix` is already the real config
generated on buildcorsair, so no action is needed on the existing machine.

Only regenerate it if the hardware changes or you reinstall on a different
machine:

```bash
sudo nixos-generate-config --show-hardware-config > ~/source/nix/machines/buildcorsair/hardware-configuration.nix
```

Review `machines/buildcorsair/default.nix` and adjust the boot loader block if
the machine boots via legacy BIOS/GRUB rather than UEFI/systemd-boot.

### Apply the configuration

```bash
sudo nixos-rebuild switch --flake ~/source/nix#buildcorsair
```

Once fish is your shell, use the `rebuild` alias for subsequent switches.

## macOS

### Install Nix and home-manager

Install Nix (e.g. the [Determinate Nix installer](https://github.com/DeterminateSystems/nix-installer)),
then clone this repo:

```bash
git clone https://github.com/m3dwards/nix.git ~/source/nix
cd ~/source/nix
```

### Apply the configuration

```bash
nix run home-manager/release-26.05 -- switch --flake ~/source/nix#maxedwards
```

After the first switch the `rebuild` alias runs
`home-manager switch --flake ~/source/nix#maxedwards`.

## Guix shell

Use the bundled dev shell for Guix work on Linux:

```bash
nix develop .#guix
```

### Manual steps to get guix builds working

1. Copy the macOS SDK(s) over and untar them.
2. Set up GPG keys for signing builds.

## Updating

Remember to push updates to `~/source/nix` to GitHub.
