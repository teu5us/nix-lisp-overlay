attrs@{ pkgs, lib, stdenv, newScope, asdf, runCommand }:

let
  buildSrc = { pname, version, src ? null, release ? null, ... }:
    assert src != null || release != null;
    stdenv.mkDerivation {
      inherit pname;
      name = "${pname}-${version}_src";
      src = if src == null
            then let
              data = releases.${release};
            in
              (pkgs.${data.fetcher}) data.src
            else src;
      phases = ["unpackPhase" "installPhase"];
      installPhase = ''
        mkdir -p $out/
        cp -r ./. $out/
      '';
    };

  releases = builtins.fromJSON (builtins.readFile ./releases.json);

  systems = builtins.fromJSON (builtins.readFile ./systems_merged.json);

  overrides = import ./overrides.nix { inherit pkgs lib; };

  scope = compiler: lib.customisation.makeScope newScope (self: with self;
    {
    inherit compiler;

    asdf = attrs.asdf.overrideAttrs (oa: {
      # patch taken from guix and modified to exclude unused variable warnings
      buildPhase = oa.buildPhase + ''
        patch -p1 -i ${./patches/cl-asdf-config-directories.patch} build/asdf.lisp
      '';
    });

    buildLispPackage = (self.callPackage ./lisp-package-builder.nix
      { inherit (self) compiler asdf;
        inherit stdenv lib buildSrc confBuilders releases;
        scope = self;
      });

    uiop = asdf;

    } // lib.mapAttrs (n: v: if lib.isAttrs v then buildLispPackage v else self.${v}) systems);
in rec {
  packagesFor = compiler:
    overrides (scope compiler);

  withPackages = compiler: pkgs.callPackage ./wrap-lisp.nix
    { inherit compiler confBuilders; scope = packagesFor compiler; };
}
