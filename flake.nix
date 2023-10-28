{
    description = "BluOS Controller (non-free)";

    inputs = {
        flake-parts.url = github:hercules-ci/flake-parts;
        nix-project.url = github:shajra/nix-project;
        bluos-controller-packed = {
            url = https://content-bluesound-com.s3.amazonaws.com/uploads/2023/10/BluOS-Controller-4.0.1-Windows.zip;
            #url = https://content-bluesound-com.s3.amazonaws.com/uploads/2023/08/BluOS-Controller-3.20.6.exe;
            #url = https://bluos.net/wp-content/uploads/2023/02/BluOS-Controller-3.20.5.exe;
            flake = false;
        };
    };

    outputs = inputs@{ flake-parts, nix-project, ... }:
        let meta.pname = "bluos-controller";
            meta.version = "4.0.1";
        in flake-parts.lib.mkFlake { inherit inputs; } ({withSystem, config, ... }: {
            imports = [ nix-project.flakeModules.nixpkgs ];
            systems = [ "x86_64-linux" ];
            perSystem = { system, nixpkgs, ... }:
                let build = import nixpkgs.stable.path {
                        inherit system;
                        config.permittedInsecurePackages = [
                            "electron-24.8.6"
                            #"electron-9.4.4"
                        ];
                        overlays = [ config.flake.overlays.default ];
                    };
                in {
                    packages.default = build.bluos-controller;
                    packages.bluos-controller = build.bluos-controller;
                    apps = rec {
                        default = bluos-controller;
                        bluos-controller = {
                            type = "app";
                            program = "${build.bluos-controller}/bin/bluos-controller";
                        };
                    };
                    legacyPackages.nixpkgs = build;
                };
            flake.overlays.default =
                import nix/overlay.nix inputs withSystem meta;
        });
}
