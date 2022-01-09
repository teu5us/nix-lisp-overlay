{ pkgs, callPackage }:

pkgs.lib.makeScope pkgs.newScope (self: with self;{

  # sbcl
  sbcl_bootstrap = callPackage ./sbcl/bootstrap.nix {};
  sbcl_2_0_8 = callPackage ./sbcl/2.0.8.nix {};
  sbcl_2_0_9 = callPackage ./sbcl/2.0.9.nix {};
  sbcl_2_1_1 = callPackage ./sbcl/2.1.1.nix {};
  sbcl_2_1_2 = callPackage ./sbcl/2.1.2.nix {};
  sbcl_2_1_9 = callPackage ./sbcl/2.1.9.nix {};
  sbcl_2_1_10 = callPackage ./sbcl/2.1.10.nix {};
  sbcl_2_1_11 = callPackage ./sbcl/2.1.11.nix {};
  sbcl = sbcl_2_1_11;
})
