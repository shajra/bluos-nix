{
  bluos-controller-win-zip,
  stdenv,
  p7zip,
}:
{
  pname,
  version,
}:

stdenv.mkDerivation {
  pname = "${pname}-unexe";
  inherit version;
  src = bluos-controller-win-zip;
  nativeBuildInputs = [ p7zip ];
  phases = [ "unpackPhase" ];
  unpackPhase = ''
    mkdir "$out"
    7zr x "$src" -o"$out"
  '';
}
