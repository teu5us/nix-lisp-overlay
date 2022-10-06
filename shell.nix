{ pkgs ? import <nixpkgs> {} }:

with pkgs // (import ./. { inherit pkgs; });

let
  lisp = newLispPackages.cclWithPackages (lp: with lp; [
    cl-async
  ]) {};
in
mkShell {
  buildInputs = [ lisp ];
}
