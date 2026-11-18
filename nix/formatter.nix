# treefmt with the standard tool set: nixfmt + deadnix + statix + keep-sorted.
# Config lives in ../treefmt.toml (treefmt-nix is no longer in nixpkgs).
{ pkgs, ... }:
pkgs.treefmt
