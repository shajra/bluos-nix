{ bluos-controller-packed
, stdenv
, p7zip
}:
{ pname
, version
}:

stdenv.mkDerivation {
    pname = "${pname}-unexe";
    inherit version;
    src = bluos-controller-packed;
    nativeBuildInputs = [ p7zip ];
    phases = [ "unpackPhase" ];
    unpackPhase = ''
        mkdir "$out"
        7zr x "$src" -o"$out"
    '';
}
