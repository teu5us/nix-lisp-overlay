{ pkgs }:

let
  scope = pkgs.callPackage ./make-lisp-scope.nix {};
in
rec {
  inherit (scope) packagesFor withPackages;

  sbclPackages = packagesFor pkgs.sbcl;
  cclPackages = packagesFor pkgs.ccl;
  eclPackages = packagesFor pkgs.ecl;

  sbclWithPackages = withPackages pkgs.sbcl;
  cclWithPackages = withPackages pkgs.ccl;
  eclWithPackages = withPackages pkgs.ecl;

  nyxt-gtk = sbclPackages.nyxt-gtk;
}
