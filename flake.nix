{
  description = "BluOS Controller (non-free)";

  inputs = {
    devshell.url = "github:numtide/devshell";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nix-project.url = "github:shajra/nix-project";
    treefmt-nix.url = "github:numtide/treefmt-nix";
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
            checks.ci = build.bluos-controller;
            legacyPackages.nixpkgs = build;
            devshells.default = {
              commands = [
                {
                  name = "project-update";
                  help = "update project dependencies";
                  command = "nix flake update --commit-lock-file";
                }
                {
                  name = "project-check";
                  help = "run all checks/tests/linters";
                  command = "nix --print-build-logs flake check --show-trace";
                }
                {
                  name = "project-format";
                  help = "format all files in one command";
                  command = ''treefmt "$@"'';
                }
                {
                  name = "project-doc-gen";
                  help = "generate GitHub Markdown from Org files";
                  command = ''org2gfm-hermetic "$@"'';
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
                ignoreEnvironment = true;
                keepEnvVars = [
                  "LANG"
                  "LOCALE_ARCHIVE"
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
                extraPaths = [
                  "/bin"
                ];
                pathIncludesActiveNix = true;
                pathIncludesPrevious = false;
                exclude = [
                  "internal"
                  "examples"
                ];
                evaluate = true;
              };
            };
          };
        flake.overlays.default = overlay;
      }
    );
}
