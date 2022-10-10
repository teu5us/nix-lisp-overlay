{ pkgs ? import <nixpkgs> {} }:

import ./lisp-modules { inherit pkgs; }
