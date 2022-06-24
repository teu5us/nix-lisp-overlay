{ pkgs }:

let
  packagesFor = pkgs.callPackage ./make-lisp-scope.nix { inherit pkgs; };
in
{
  sbcl = packagesFor pkgs.sbcl;
  ccl = packagesFor pkgs.ccl;
}
