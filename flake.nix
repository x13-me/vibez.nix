# Thin flake root: all outputs live in `./nix` (see `nix/default.nix`).
{
  description = "VibeZ — desktop client for Mistral Vibe — on Nix";

  inputs = {
    # github ref: correct git-rev pinning, changelog tooling, fleet consistency.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ./nix inputs;
}
