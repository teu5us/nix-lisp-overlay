{ pkgs }:

let
  callPackage = pkgs.callPackage;
in
{
  lispPackages = callPackage ./lisp-modules {};
}
