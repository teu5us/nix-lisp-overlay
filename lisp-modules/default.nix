{ pkgs }:

let
  packagesFor = pkgs.callPackage ./make-lisp-scope.nix {};
in
{
  sbcl = packagesFor pkgs.sbcl;
  ccl = packagesFor pkgs.ccl;
}
