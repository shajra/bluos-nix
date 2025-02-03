{ bluos-controller-linux-unpacked
, ripgrep
, nodePackages
, stdenv
}:
{ pname
, version
}:

let
    # DESIGN: Looking at Nixpkgs, it seems like Electron application resources
    # are typically patched in with substituteInPlace, which is what we're doing
    # below.  Regex pattern matching makes gives us some wiggle room in case the
    # minified variable name changes.
    replaceWithinPackagesJs = replaced: replacement: ''
        rg --type js --files-with-matches "${replaced}" packages \
        | while read -r js
        do
            # DESIGN: Not using substituteInPlace to get regex matching.
            sed --in-place --regexp-extended "s#${replaced}#${replacement}#g" $js
        done
    '';
in stdenv.mkDerivation {
    pname = "${pname}-appimage";
    inherit version;
    src = bluos-controller-linux-unpacked;
    nativeBuildInputs = [
        ripgrep
        nodePackages.asar
    ];
    phases = ["unpackPhase" "installPhase"];
    unpackPhase = ''
        asar extract "$src/resources/app.asar" .

        ${replaceWithinPackagesJs "[a-z]+\\.resourcesPath" "\\\"$out/resources\\\""}

        # DESIGN: We're going to by default take all the logic for Macs as our
        # logic for Linux.
        ${replaceWithinPackagesJs "\\\"linux\\\""  "\\\"_linux\\\""}
        ${replaceWithinPackagesJs "\\\"darwin\\\"" "\\\"linux\\\""}
        ${replaceWithinPackagesJs "\\\"MacOS\\\""  "\\\"Linux\\\""}

        # DESIGN: 4.8.0: Within a function returning the upgrade URL
        ${replaceWithinPackagesJs "desktop_app/osx/" "desktop_app/windows/"}

        # DESIGN: We want one deviation from Mac behavior of actually quitting
        # when all windows are closed.
        ${replaceWithinPackagesJs "&& ([a-z]+\\.quit\\(\\))" "|| \\1"}

    '';
    installPhase = ''
        mkdir --parents "$out"
        cp -r . "$out"
        mkdir --parents "$out/resources"
        cp -r "$src/resources/analytics" "$out/resources"
    '';
}
