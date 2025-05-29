{
    description = "BluOS Controller (non-free)";

    inputs = {
        flake-parts.url = "github:hercules-ci/flake-parts";
        nix-project.url = "github:shajra/nix-project";
        bluos-controller-win-zip = {
            url = "https://content-bluesound-com.s3.amazonaws.com/uploads/BluOS-Controller-4.8.0-Windows.zip";
            flake = false;
        };
        bluos-controller-mac-zip = {
            url = "https://content-bluesound-com.s3.amazonaws.com/uploads/2025/01/BluOS-Controller-4.8.0-MacOS.zip";
            flake = false;
        };
    };

    outputs = inputs@{ flake-parts, nix-project, ... }:
        let meta.pname = "bluos-controller";
            meta.version = "4.8.0";
        in flake-parts.lib.mkFlake { inherit inputs; } ({withSystem, config, ... }: {
            imports = [ nix-project.flakeModules.nixpkgs ];
            systems = [
                "x86_64-linux"
                "x86_64-darwin"
                "aarch64-darwin"
            ];
            perSystem = { nixpkgs, ... }:
                let build = nixpkgs.stable.extend
                        config.flake.overlays.default;
                in {
                    packages.default = build.bluos-controller;
                    packages.bluos-controller = build.bluos-controller;
                    apps = rec {
                        default = bluos-controller;
                        bluos-controller = {
                            type = "app";
                            program = "${build.bluos-controller}/bin/bluos-controller";
                            inherit (build.bluos-controller) meta;
                        };
                    };
                    checks.ci         = build.bluos-controller;
                    legacyPackages.nixpkgs = build;
                };
            flake.overlays.default =
                import nix/overlay.nix inputs withSystem meta;
        });
}
