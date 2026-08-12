{
  asar,
  bluos-controller-linux-unpacked,
  ripgrep,
  stdenv,
}:
{
  pname,
  version,
}:

let
  # DESIGN: Looking at Nixpkgs, it seems like Electron application resources
  # are typically patched in with substituteInPlace, which is what we're doing
  # below.  Regex pattern matching makes gives us some wiggle room in case the
  # minified variable name changes.
  appJsPath = "node_modules/@app/main/dist";

  replaceWithinAppJs = replaced: replacement: ''
    while IFS= read -r js
    do
        test -n "$js" || continue
        # DESIGN: Not using substituteInPlace to get regex matching.
        sed --in-place --regexp-extended "s#${replaced}#${replacement}#g" "$js"
    done <<< "$(rg --type js --files-with-matches "${replaced}" ${appJsPath} || true)"
  '';
in
stdenv.mkDerivation {
  pname = "${pname}-appimage";
  inherit version;
  src = bluos-controller-linux-unpacked;
  nativeBuildInputs = [
    asar
    ripgrep
  ];
  phases = [
    "unpackPhase"
    "installPhase"
  ];
  unpackPhase = ''
    asar extract "$src/resources/app.asar" .

    test -d ${appJsPath}

    ${replaceWithinAppJs "[a-z0-9$]+\\.resourcesPath" "\\\"$out/resources\\\""}

    # DESIGN: 4.16.0 moved the window-close behavior from stopApp() into this
    # platform check. Keep Linux quitting even after the Darwin-to-Linux rewrite.
    ${replaceWithinAppJs "if \\(platform !== \\\"darwin\\\"\\) app\\.quit\\(\\);" "app.quit(); process.exit(0);"}

    # DESIGN: We're going to by default take all the logic for Macs as our
    # logic for Linux.
    ${replaceWithinAppJs "\\\"linux\\\"" "\\\"_linux\\\""}
    ${replaceWithinAppJs "\\\"darwin\\\"" "\\\"linux\\\""}
    ${replaceWithinAppJs "\\\"MacOS\\\"" "\\\"Linux\\\""}
  '';
  installPhase = ''
    mkdir --parents "$out"
    cp -r . "$out"
    mkdir --parents "$out/resources"
    cp -r "$src/resources/analytics" "$out/resources"
  '';
}
