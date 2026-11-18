# Main flake outputs (imported by the thin `flake.nix`).
# Small-flake layout, no flake-parts/flake-utils/haumea:
# `forAllSystems` is just `lib.genAttrs` over `legacyPackages`.
{ nixpkgs, ... }:

let
  inherit (nixpkgs) lib;
  myLib = import ../lib { inherit lib; };
  inherit (myLib) systems;

  pkgsFor = system: nixpkgs.legacyPackages.${system};
  forAllSystems = fn: lib.genAttrs systems (s: fn (pkgsFor s));

  scopeFor = pkgs: import ../packages { inherit pkgs; };
  publicNames = [
    # keep-sorted start
    "vibez3"
    "vibez4-beta"
    # keep-sorted end
  ];
  isUsableOn = pkgs: _: pkg:
    lib.isDerivation pkg
    && !(pkg.meta.broken or false)
    && lib.meta.availableOn pkgs.stdenv.hostPlatform pkg;
  packages = forAllSystems (pkgs:
    let scope = scopeFor pkgs;
    in lib.filterAttrs (isUsableOn pkgs) (lib.getAttrs publicNames scope));
  formatterFor = pkgs: pkgs.callPackage ./formatter.nix { };
  legacyPackages = forAllSystems (pkgs: lib.filterAttrs (_: lib.isDerivation) (scopeFor pkgs));
in
{
  inherit packages;
  devShells = forAllSystems (pkgs:
    let formatter = formatterFor pkgs; in {
      default = pkgs.mkShellNoCC {
        packages = [ pkgs.git ] ++ formatter.runtimeInputs;
        env.DIRENV_LOG_FORMAT = "";
      };
    });
  checks = forAllSystems (pkgs:
    let formatter = formatterFor pkgs; in {
      formatting = pkgs.runCommandLocal "vibez-nix-formatting-check" {
        src = lib.cleanSource ../.;
        nativeBuildInputs = [ formatter ];
      } ''
        cd "$src"
        treefmt --tree-root-file flake.nix --ci
        touch "$out"
      '';
    });
  formatter = forAllSystems formatterFor;
  hydraJobs =
    let
      jobsFor = system:
        let
          available = packages.${system};
          present = lib.filter (name: available ? ${name}) publicNames;
        in
        map (name: lib.nameValuePair "${name}-${system}" available.${name}) present;
    in
    lib.listToAttrs (lib.concatMap jobsFor systems);
  lib = myLib;
}
