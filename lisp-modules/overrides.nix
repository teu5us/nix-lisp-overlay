{ pkgs, lib }:

scope:

scope.overrideScope' (self': super': {

  resolveLispInputs = import ./resolve-lisp-inputs.nix { inherit lib; scope = super'; };

  cffi = super'.cffi.overrideAttrs (oa: {
    nativeBuildInputs = [ pkgs.pkg-config ];
    propagatedBuildInputs = oa.propagatedBuildInputs
                            ++ [ pkgs.libffi pkgs.libffi.dev pkgs.gcc ];
  });

})
