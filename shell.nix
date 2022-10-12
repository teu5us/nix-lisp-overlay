{ pkgs ? import <nixpkgs> {} }:

with pkgs // (import ./. { inherit pkgs; });

let
  lisp = sbclWithPackages (lp: with lp; [
    cl-async
    pkgs.gsl
  ]);
in
  mkShell {
    buildInputs = [ lisp ];
  }
