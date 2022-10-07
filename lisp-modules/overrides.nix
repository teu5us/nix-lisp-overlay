{ pkgs, lib }:

scope:

scope.overrideScope' (self: super: {

  cl-libuv = super.cl-libuv.overrideAttrs (oa: {
    lispInputs = oa.lispInputs ++ [ self.cffi-grovel ];
    propagatedBuildInputs = oa.propagatedBuildInputs ++ [ pkgs.libuv ];
  });

  cl_plus_ssl_merged = super.cl_plus_ssl_merged.overrideAttrs (oa: {
    propagatedBuildInputs = oa.propagatedBuildInputs ++ [ pkgs.openssl.out ];
  });

  swank = super.swank.overrideAttrs (oa: {
    extraFiles = [
      "swank" "contrib" "lib"
      "metering.lisp"
      "nregex.lisp"
      "packages.lisp"
      "sbcl-pprint-patch.lisp"
      "start-swank.lisp"
      "swank-loader.lisp"
      "swank.lisp"
      "xref.lisp"
    ];
  });

  cl-async = super.cl-async.overrideAttrs (oa: {
    providedSystems = [ "cl-async" ];
  });

  static-vectors = super.static-vectors.overrideAttrs (oa: {
    extraFiles = [ "version.sexp" ];
  });

  trivial-with-current-source-form = super.trivial-with-current-source-form.overrideAttrs (oa: {
    extraFiles = [ "version-string.sexp" ];
  });

  usocket = super.usocket.overrideAttrs (oa: {
    extraFiles = [ "version.sexp" ];
  });

})
