{ pkgs ? import <nixpkgs> {} }:

with pkgs // (import ./. { inherit pkgs; });

let
  lisp = eclWithPackages (lp: with lp; [
    cl-async
  ]) {};
in
mkShell {
  buildInputs = [ lisp ];
}
