{ pkgs ? import <nixpkgs> {} }:

with pkgs;

let
  lp = callPackage ./default.nix {  };
in
lp
  # mkShell {
  #   buildInputs = [ lp.packages.sbcl' lp.packages.ccl' ];
  # }
