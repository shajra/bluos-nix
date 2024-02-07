{ bluos-controller-mac-zip
, stdenv
, undmg
}:
{ pname
, version
}:

stdenv.mkDerivation {
    pname = "${pname}-undmg";
    inherit version;
    src = bluos-controller-mac-zip;
    nativeBuildInputs = [ undmg ];
    unpackPhase = ''
        undmg "$src"
    '';
    installPhase = ''
        mkdir "$out"
        cp -r . "$out"
    '';
}
