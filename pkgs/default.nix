{ pkgs }:

let
  callPackage = pkgs.callPackage;
in
{
  compilers = callPackage ./development/compilers {};
  packages = callPackage ./development/lisp-modules {};
}
