{ pkgs ? import <nixpkgs> {} }:

let
  callPackage = pkgs.callPackage;
in
{
  newLispPackages = callPackage ./lisp-modules {};
}
