{
  description = "BluOS Controller (non-free)";

  inputs = {
    nix-project.url = "github:shajra/nix-project";
    devshell.follows = "nix-project/devshell";
    flake-parts.follows = "nix-project/flake-parts";
    treefmt-nix.follows = "nix-project/treefmt-nix";
    bluos-controller-win-zip = {
      url = "https://bluos.io/wp-content/uploads/2025/07/BluOS-Controller-4.10.0-Windows.zip";
      flake = false;
    };
    bluos-controller-mac-zip = {
      url = "https://bluos.io/wp-content/uploads/2025/07/BluOS-Controller-4.10.0-MacOS.zip";
      flake = false;
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    let
      meta.pname = "bluos-controller";
      meta.version = "4.10.0";
    in
    flake-parts.lib.mkFlake { inherit inputs; } (
      { withSystem, ... }:
      let
        overlay = import nix/overlay.nix inputs withSystem meta;
      in
      {
        imports = [
          inputs.nix-project.flakeModules.nixpkgs
          inputs.nix-project.flakeModules.org2gfm
          inputs.devshell.flakeModule
          inputs.treefmt-nix.flakeModule
        ];
        systems = [
          "x86_64-linux"
          "x86_64-darwin"
          "aarch64-darwin"
        ];
        perSystem =
          { config, nixpkgs, ... }:
          let
            build = nixpkgs.stable.extend overlay;
          in
          {
            _module.args.pkgs = nixpkgs.stable;
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
            checks.build = build.bluos-controller-checks;
            legacyPackages.nixpkgs = build;
            devshells.default = {
              commands = [
                {
                  category = "[general commands]";
                  name = "project-format";
                  help = "format all files in one command";
                  command = ''treefmt "$@"'';
                }
                {
                  category = "[release]";
                  name = "project-update";
                  help = "1) update project dependencies";
                  command = ''nix flake update --commit-lock-file "$@"'';
                }
                {
                  category = "[release]";
                  name = "project-check";
                  help = "2) run all checks/tests/linters";
                  command = "nix --print-build-logs flake check --show-trace";
                }
                {
                  category = "[release]";
                  name = "project-doc-gen";
                  help = "3) generate GitHub Markdown from Org files";
                  command = ''org2gfm "$@"'';
                }
              ];
              packages = [
                config.treefmt.build.wrapper
                config.org2gfm.finalPackage
              ];
            };
            treefmt.pkgs = nixpkgs.unstable;
            treefmt.programs = {
              deadnix.enable = true;
              nixfmt.enable = true;
              nixf-diagnose.enable = true;
            };
            org2gfm = {
              settings = {
                envKeep = [
                  "LANG"
                  "LOCALE_ARCHIVE"
                ];
                pathKeep = [
                  "nix"
                ];
                pathPackages = [
                  nixpkgs.stable.ansifilter
                  nixpkgs.stable.coreutils
                  nixpkgs.stable.git
                  nixpkgs.stable.gnugrep
                  nixpkgs.stable.gnutar
                  nixpkgs.stable.gzip
                  nixpkgs.stable.jq
                  nixpkgs.stable.nixfmt-rfc-style
                  nixpkgs.stable.tree
                ];
                pathExtras = [
                  "/bin"
                ];
                exclude = [
                  "internal"
                ];
                evaluate = true;
              };
            };
          };
        flake.overlays.default = overlay;
      }
    );
}
