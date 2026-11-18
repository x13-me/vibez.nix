{ lib }:
lib.makeExtensible (_final: {
  /**
    Nix systems this flake builds for.
    Single source of truth: `nix/default.nix` derives `forAllSystems` from this list.
  */
  systems = [ "x86_64-linux" ];
})
