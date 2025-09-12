{
  bluos-controller-darwin-unpacked,
  makeWrapper,
  stdenv,
}:
{
  pname,
  version,
}:

let
  desktopName = "BluOS Controller";
  exeName = "BluOS Controller";
in
stdenv.mkDerivation {
  pname = "${pname}-appimage";
  inherit version;
  src = bluos-controller-darwin-unpacked;
  nativeBuildInputs = [ makeWrapper ];
  phases = [ "installPhase" ];
  installPhase = ''
    runHook preInstall
    mkdir --parents "$out/Applications"
    cp -r "$src/${desktopName}.app" "$out/Applications"
    mkdir --parents "$out/bin"
    makeWrapper \
        "$out/Applications/${desktopName}.app/Contents/MacOS/${exeName}" \
        "$out/bin/bluos-controller"
    runHook postInstall
  '';
}
