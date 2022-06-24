{ pkgs }:

let
  callPackage = pkgs.callPackage;
in
{
  newLispPackages = callPackage ./lisp-modules {};
}
