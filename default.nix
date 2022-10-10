{ pkgs ? import <nixpkgs> {} }:

pkgs.callPackage ./lisp-modules {}
