# lecomputeur/vibez — VibeZ desktop client for Mistral Vibe (Rust + Tauri).
#
# Ships as prebuilt .deb release assets; unpacked here rather than built from
# source (a Tauri build needs the full webkitgtk toolchain and a node frontend
# build for no practical gain over upstream's artifacts).
#
# Two variants, since upstream tracks both lines:
#   v3       — stable line, binary `vibez3`
#   v4-beta  — v4 beta line, binary `vibez4-alpha`
{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  makeWrapper,
  glib,
  gtk3,
  cairo,
  pango,
  gdk-pixbuf,
  atk,
  webkitgtk_4_1,
  libsoup_3,
  openssl,
  libayatana-appindicator,
  python3,
  bubblewrap,
  variant,
}:
let
  versions = import ../../versions.nix;
  release = versions.vibez.${variant};
  system = stdenv.hostPlatform.system;
in
stdenv.mkDerivation {
  pname = if variant == "v3" then "vibez" else "vibez4-beta";
  inherit (release) version;

  src = fetchurl {
    url = "https://github.com/lecomputeur/vibez/releases/download/${release.tag}/VibeZ-${release.version}-Linux-x64.deb";
    hash = release.systems.${system}.deb or release.deb;
  };

  nativeBuildInputs = [
    dpkg
    makeWrapper
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    dpkg-deb -x "$src" unpacked

    mkdir -p "$out"
    cp -r unpacked/usr/bin "$out/bin"
    cp -r unpacked/usr/share "$out/share"
    cp -r unpacked/usr/lib "$out/lib" 2>/dev/null || true

    mv "$out/bin/${release.binaryName}" "$out/bin/.${release.binaryName}-unwrapped"
    # v4-beta execve's /usr/bin/python3 by absolute path; bind the nix python3
    # there with bubblewrap. v3 doesn't need it but the bind is harmless.
    makeWrapper "$out/bin/.${release.binaryName}-unwrapped" "$out/bin/${release.binaryName}" \
      --run "exec ${bubblewrap}/bin/bwrap --bind / / --bind ${python3}/bin/python3 /usr/bin/python3 -- \"$out/bin/.${release.binaryName}-unwrapped\"" \
      --suffix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          glib
          gtk3
          cairo
          pango
          gdk-pixbuf
          atk
          webkitgtk_4_1
          libsoup_3
          openssl
          libayatana-appindicator
        ]
      }

    runHook postInstall
  '';

  meta = {
    description = "VibeZ — cross-platform desktop client for Mistral Vibe (${variant})";
    homepage = "https://github.com/lecomputeur/vibez";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = release.binaryName;
  };
}
