# ccache — system-wide compiler cache.
#
# Machine-level on purpose, not home-manager and definitely not agents.nix:
#  - the *binary* should exist for every account on the box, including root;
#  - the *cache* has to be writable by whoever compiles, so it must live outside any home
#    directory and be shared by every checkout (git worktrees included).
#
# Gotcha: `programs.ccache.enable` on its own installs nothing and exports nothing. It creates the
# cache directory with a tmpfiles rule, adds a setgid `nix-ccache` stats wrapper, and optionally
# rebuilds named nixpkgs packages with ccacheStdenv. The binary and CCACHE_DIR are done by hand
# below.
{ pkgs, ... }:
{
  programs.ccache = {
    enable = true;
    # Upstream default is `nixbld`, which only the build daemon belongs to. Interactive accounts
    # are in `users`, so tmpfiles creates /var/cache/ccache root:users 0770 and max can write it.
    group = "users";
  };

  environment.systemPackages = [ pkgs.ccache ];

  environment.sessionVariables = {
    CCACHE_DIR = "/var/cache/ccache";
    # Group-writable cache entries, so objects written by max and by root are both usable and
    # `ccache -s` as either user reports the same hit rate.
    CCACHE_UMASK = "007";
  };
}
