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

  scope = compiler: lib.customisation.makeScope newScope (self: with self; {
    inherit compiler asdf;

    uiop = asdf;

    buildLispPackage = (self.callPackage ./lisp-package-builder.nix
        { inherit stdenv lib compiler asdf; });

    cl2nix = callPackage ./packages/cl2nix {};
    ubiquitous = callPackage ./packages/ubiquitous {};
    alexandria = callPackage ./packages/alexandria {};
    trivial-features = callPackage ./packages/trivial-features {};
    trivial-gray-streams = callPackage ./packages/trivial-gray-streams {};
    babel = callPackage ./packages/babel {};
    cl-ppcre = callPackage ./packages/cl-ppcre {};
    cl-json = callPackage ./packages/cl-json {};
    cffi = callPackage ./packages/cffi {};
  });
in rec {
  packagesFor = compiler:
    (scope compiler).overrideScope' (self': super': {
      cffi = super'.cffi.overrideAttrs (oa: {
        nativeBuildInputs = [ pkgs.pkg-config ];
        propagatedBuildInputs = oa.propagatedBuildInputs ++ [ pkgs.libffi pkgs.libffi.dev pkgs.gcc ];
      });
    });

  withPackages = compiler: pkgs.callPackage ./wrap-lisp.nix
    { inherit compiler; scope = packagesFor compiler; };
}
