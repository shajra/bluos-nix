{
    description = "BluOS Controller (non-free)";

    inputs = {
        flake-parts.url = github:hercules-ci/flake-parts;
        nix-project.url = github:shajra/nix-project;
        bluos-controller-packed = {
            url = https://content-bluesound-com.s3.amazonaws.com/uploads/2024/01/BluOS-Controller-4.2.1-Windows.zip;
            flake = false;
        };
    };

    outputs = inputs@{ flake-parts, nix-project, ... }:
        let meta.pname = "bluos-controller";
            meta.version = "4.2.1";
        in flake-parts.lib.mkFlake { inherit inputs; } ({withSystem, config, ... }: {
            imports = [ nix-project.flakeModules.nixpkgs ];
            systems = [ "x86_64-linux" ];
            perSystem = { system, nixpkgs, ... }:
                let build = import nixpkgs.stable.path {
                        inherit system;
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
                    legacyPackages.ci = build.bluos-controller;
                };
            flake.overlays.default =
                import nix/overlay.nix inputs withSystem meta;
        });
}
