# System-independent on purpose: `prev.callPackage` only, never flake outputs.
_: prev: {
  vibez3 = prev.callPackage ../packages/vibez/package.nix { variant = "v3"; };
  vibez4-beta = prev.callPackage ../packages/vibez/package.nix { variant = "v4-beta"; };
}
