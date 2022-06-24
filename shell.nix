{ pkgs ? import <nixpkgs> {} }:

with pkgs // (import ./. { inherit pkgs; });

mkShell {
  buildInputs = [
    (newLispPackages.sbcl.withPackages (lp: with lp; [
    ]))
  ];
}
