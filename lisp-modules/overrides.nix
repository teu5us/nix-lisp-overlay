{ pkgs, lib }:

scope:

scope.overrideScope' (self: super: {

  cl-libuv = super.cl-libuv.overrideAttrs (oa: {
    lispInputs = oa.lispInputs ++ [ self.cffi-grovel ];
    propagatedBuildInputs = oa.propagatedBuildInputs ++ [ pkgs.libuv ];
  });

  cl-async = super.cl-async.overrideAttrs (oa: {
    providedSystems = [ "cl-async" ];
  });

  static-vectors = super.static-vectors.overrideAttrs (oa: {
    extraFiles = [ "version.sexp" ];
  });

})
