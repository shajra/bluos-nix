{ externalOverrides ? {}
}:

let

    external = import ./external // externalOverrides;

    nix-project = import external.nix-project;

    nixpkgs = import external.nixpkgs {
        config = {
            permittedInsecurePackages = [ "electron-9.4.4" ];
        };
        overlays = [(self: super: nix-project)];
    };

    src = external."bluos-controller.dmg";
    pname = "bluos-controller";
    version = "3.14.1";
    name = "${pname}-${version}";

    meta.description = "BluOS Controller ${version} (non-free)";
    meta.platforms = nixpkgs.lib.platforms.linux;

    undmg = nixpkgs.stdenv.mkDerivation {
        inherit version src;
        pname = "${pname}-undmg";
        nativeBuildInputs = [ nixpkgs.undmg ];
        unpackPhase = ''
            undmg "$src"
        '';
        sourceRoot = "BluOS Controller.app/Contents";
        installPhase = ''
            mkdir "$out"
            cp -r . "$out"
        '';
    };

    unasar = patches: nixpkgs.stdenv.mkDerivation {
        pname = "${pname}-appimage";
        inherit version patches;
        src = undmg;
        nativeBuildInputs = with nixpkgs.nodePackages; [
            asar
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
            asar extract "$src/Resources/app.asar" .
            js-beautify -r www/app.js
        '';
        installPhase = ''
            mkdir --parents "$out"
            cp -r . "$out"
            mkdir --parents "$out/resources"
            cp -r "$src/Resources/analytics" "$out/resources"
        '';
    };

    unasar-patched = unasar [ ./patch ];
    unasar-unpatched = unasar [];

    bluos-controller = nixpkgs.callPackage ./wrapper.nix {
        inherit pname meta unasar-patched;
    };

    distribution = { inherit bluos-controller; };

# DESIGN: can be useful for regenerating the patch file
#in { inherit undmg unasar-unpatched; }
in { inherit distribution nix-project nixpkgs; }
