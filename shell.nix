{ pkgs ? import <nixpkgs> {} }:

with pkgs // (import ./. { inherit pkgs; });

let
  lisp = newLispPackages.sbclWithPackages (lp: with lp; [
    cl2nix
    cffi
  ]) { extras = [ pkgs.libffi.dev ]; };
in
# lisp
mkShell {
  buildInputs = [ lisp ];
}
