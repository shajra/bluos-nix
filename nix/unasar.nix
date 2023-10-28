{ bluos-controller-unpacked
, dos2unix
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
    nativeBuildInputs = with nodePackages; [
        asar
        dos2unix
        js-beautify
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
        dos2unix common/mainWindow.js
        js-beautify -r www/assets/index-*.js
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
        mkdir "$out/icons" && cp www/img/icon.png "$out/icons/256x256.png"
    '';
}
