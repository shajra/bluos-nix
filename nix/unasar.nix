{ bluos-controller-unpacked
, nodePackages
, stdenv
}:
{ pname
, version
}:
patches:

stdenv.mkDerivation {
    pname = "${pname}-appimage";
    inherit version patches;
    src = bluos-controller-unpacked;
    patchFlags = [ "-p1" ];
    nativeBuildInputs = [
        nodePackages.asar
    ];
    phases = ["unpackPhase" "patchPhase" "postPhase" "installPhase"];
    postPhase = ''
        substituteInPlace common/analyticsServer.js \
            --replace \
            'process.resourcesPath' \
            "\"$out/resources\""
    '';
    unpackPhase = ''
        asar extract "$src/resources/app.asar" .
        substituteInPlace www/assets/*.js \
            --replace  \
            '"linux"' \
            '"_linux"'
        substituteInPlace www/assets/*.js \
            --replace  \
            '"darwin"' \
            '"linux"'
        substituteInPlace www/assets/*.js \
            --replace  \
            '"MacOS"' \
            '"Linux"'
    '';
    installPhase = ''
        mkdir --parents "$out"
        cp -r . "$out"
        mkdir --parents "$out/resources"
        cp -r "$src/resources/analytics" "$out/resources"
    '';
}
