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
        ls -la "$src"
        undmg "$src/"*.dmg
    '';
    installPhase = ''
        mkdir "$out"
        cp -r . "$out"
    '';
}
