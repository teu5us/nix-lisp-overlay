{ pkgs ? import <nixpkgs> {} }:

with pkgs;

let
  lp = callPackage ./default.nix {  };
in
## whole set for repl
# lp

## single package
# lp.packages.sbcl.alexandria

## sbcl with packages
lp.packages.sbcl.lispWithPackages [
      "trivial-with-current-source-form"
    ]

## shell
# mkShell {
#   buildInputs = [
#     (lp.packages.sbcl.lispWithPackages (lp: with lp; [
#       trivial-with-current-source-form
#     ]))
#     # lp.packages.ccl
#   ];
# }
