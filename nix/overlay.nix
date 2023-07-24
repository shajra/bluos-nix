inputs: withSystem: meta:
final: prev:

let

    system = prev.stdenv.hostPlatform.system;
    patches = [ ./patches/${meta.version}-linux.patch ];

in withSystem system ({ inputs', ... }: {
    inherit (inputs) bluos-controller-packed;
    nix-project-lib = inputs'.nix-project.legacyPackages.lib.scripts;
    org2gfm = inputs'.nix-project.packages.org2gfm;
    bluos-controller-unpacked = final.callPackage ./unexe.nix {} meta;
    bluos-controller-unasar-patched
        = final.callPackage ./unasar.nix {} meta patches;
    bluos-controller-unasar-unpatched
        = final.callPackage ./unasar.nix {} meta [];
    bluos-controller
        = final.callPackage ./wrapper.nix {} meta;
})
