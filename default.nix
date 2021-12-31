{ pkgs ? import <nixpkgs> {} }:

with pkgs;

let
  packagesFor = import ./make-lisp-scope.nix pkgs;
  sbcl = packagesFor pkgs.sbcl;
  ccl = packagesFor pkgs.ccl;
in
mkShell {
  buildInputs = [
    (sbcl.withPackages (lp: [ lp.alexandria ]))
    (ccl.withPackages (lp: [ lp.alexandria ]))
  ];
}
