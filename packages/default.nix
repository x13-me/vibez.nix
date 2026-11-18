{ pkgs }: pkgs.lib.makeScope pkgs.newScope (self: {
  vibez3 = self.callPackage ./vibez/package.nix { variant = "v3"; };
  vibez4-beta = self.callPackage ./vibez/package.nix { variant = "v4-beta"; };
})
