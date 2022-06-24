{ pkgs }:

let
  callPackage = pkgs.callPackage;
in
{
  packages = callPackage ./lisp-modules {};
}
