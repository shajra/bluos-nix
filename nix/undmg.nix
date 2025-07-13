{ bluos-controller-mac-zip
, stdenv
, _7zz
}:
{ pname
, version
}:

stdenv.mkDerivation {
    pname = "${pname}-undmg";
    inherit version;
    src = bluos-controller-mac-zip;
    nativeBuildInputs = [ _7zz ];
    unpackPhase = ''
        7zz x "$src/"*.dmg
    '';
    installPhase = ''
        mkdir "$out"
        cp -r . "$out"
    '';
}
