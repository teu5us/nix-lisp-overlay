{ pkgs, lib, stdenv, newScope, asdf, runCommand }:

let
  list_NonRecursive = t:
    with lib;
    dir: mapAttrsToList (name: type: name)
      (filterAttrs (name: type: type == t)
        (builtins.readDir dir));

  listDirsNonRecursive = dir:
    map (name: dir + ("/" + name)) (list_NonRecursive "directory" dir);

  listFilesNonRecursive = dir: list_NonRecursive "regular" dir;

  filename = path: lib.last (lib.splitString "/" (toString path));

  releases = builtins.fromJSON (builtins.readFile ./releases.json);

  overrides = import ./overrides.nix { inherit pkgs lib; };

  scope = compiler: lib.customisation.makeScope newScope (self: with self;
    let
      buildLispPackage = (self.callPackage ./lisp-package-builder.nix
        { inherit (self) compiler asdf resolveLispInputs;
          inherit stdenv lib;
        });
    in
    {
    inherit compiler asdf buildLispPackage;

    uiop = asdf;

    # cl2nix = callPackage ./packages/cl2nix {};
    # ubiquitous = callPackage ./packages/ubiquitous {};
    # alexandria = callPackage ./packages/alexandria {};
    # trivial-features = callPackage ./packages/trivial-features {};
    # trivial-gray-streams = callPackage ./packages/trivial-gray-streams {};
    # babel = callPackage ./packages/babel {};
    # cl-ppcre = callPackage ./packages/cl-ppcre {};
    # cl-json = callPackage ./packages/cl-json {};
    # cffi = callPackage ./packages/cffi {};
    } // lib.mapAttrs (n: v: buildLispPackage v) releases);
in rec {
  packagesFor = compiler:
    overrides (scope compiler);

  withPackages = compiler: pkgs.callPackage ./wrap-lisp.nix
    { inherit compiler; scope = packagesFor compiler; };
}
