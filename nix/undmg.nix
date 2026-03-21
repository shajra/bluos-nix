{
  bluos-controller-mac-zip,
  stdenv,
  _7zz,
}:
{
  pname,
  version,
}:

let
  appName = "BluOS Controller";
in
stdenv.mkDerivation {
  pname = "${pname}-undmg";
  inherit version;
  src = bluos-controller-mac-zip;
  nativeBuildInputs = [ _7zz ];
  unpackPhase = ''
    7zz -snld x "$src/"*.dmg
  '';
  installPhase = ''
    mkdir "$out"
    cp -r "${appName} ${version}-universal/${appName}.app" "$out"
  '';
}
