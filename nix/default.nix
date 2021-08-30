{ externalOverrides ? {}
}:

let

    external = import ./external // externalOverrides;

    nixpkgs = import external.nixpkgs {
        config = {};
        overlays = [
            (self: super: import external.nix-project)
            (self: super: { bluos-controller = app; })
        ];
    };

    src = external."bluos-controller.dmg";
    pname = "bluos-controller";
    version = "3.14.0";
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
        phases = ["unpackPhase" "patchPhase" "installPhase"];
        unpackPhase = ''
            asar extract "$src/Resources/app.asar" .
            js-beautify -r www/app.js
        '';
        installPhase = ''
            mkdir "$out"
            cp -r . "$out"
        '';
    };

    unasar-patched = unasar [ ./patch ];
    unasar-unpatched = unasar [];

    app = nixpkgs.callPackage ./wrapper.nix {
        inherit pname meta unasar-patched;
    };

# DESIGN: can be useful for regenerating the patch file
#in { inherit app unasar-patched unasar-unpatched; }
in nixpkgs
