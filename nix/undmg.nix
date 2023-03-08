{ bluos-controller-packed
, stdenv
, undmg
}:
{ pname
, version
}:

stdenv.mkDerivation {
    pname = "${pname}-undmg";
    inherit version;
    src = bluos-controller-packed;
    nativeBuildInputs = [ undmg ];
    unpackPhase = ''
        undmg "$src"
    '';
    installPhase = ''
        mkdir "$out"
        cp -r . "$out"
    '';
}
