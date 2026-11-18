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

    mkdir -p "$out/bin" "$out/share"
    cp -r unpacked/usr/share/applications "$out/share/"
    cp -r unpacked/usr/share/icons "$out/share/"
    install -Dm755 "unpacked/usr/bin/${release.binaryName}" "$out/bin/${release.binaryName}"

    wrapProgram "$out/bin/${release.binaryName}" \
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
