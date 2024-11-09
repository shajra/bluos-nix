inputs: withSystem: meta:
final: prev:

let

    inherit (prev.stdenv.hostPlatform) system;
    bluos-controller = { bluos-controller-darwin, bluos-controller-linux, stdenv }:
        if stdenv.isDarwin
        then bluos-controller-darwin
        else bluos-controller-linux;

in withSystem system ({ inputs', ... }: {
    inherit (inputs) bluos-controller-win-zip bluos-controller-mac-zip;
    nix-project-lib = inputs'.nix-project.legacyPackages.lib.scripts;
    inherit (inputs'.nix-project.packages) org2gfm;
    bluos-controller-linux-unpacked  = final.callPackage ./unexe.nix  {} meta;
    bluos-controller-linux-patched   = final.callPackage ./linux.nix  {} meta;
    bluos-controller-linux           = final.callPackage ./daemon.nix {} meta;
    bluos-controller-darwin-unpacked = final.callPackage ./undmg.nix  {} meta;
    bluos-controller-darwin          = final.callPackage ./darwin.nix {} meta;
    bluos-controller                 = final.callPackage bluos-controller {};
})
