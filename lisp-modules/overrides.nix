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

  cl-gopher = super.cl-gopher.overrideAttrs (oa: {
    propagatedBuildInputs = oa.propagatedBuildInputs ++ [ pkgs.openssl.out ];
  });

  cl-async = super.cl-async.overrideAttrs (oa: {
    providedSystems = [ "cl-async" ];
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

  cl-unicode = super.cl-unicode.overrideAttrs (oa: {
    lispInputs = oa.lispInputs ++ [ super.flexi-streams ];
    systemFiles = lib.filter (f: ! lib.elem f [
      "lists.lisp" "hash-tables.lisp" "methods.lisp"
    ]) oa.systemFiles;
    extraFiles = [ "build" "test" ];
  });

  quri = super.quri.overrideAttrs (oa: {
    extraFiles = [ "data" ];
  });

  cl-tld = super.cl-tld.overrideAttrs (oa: {
    extraFiles = [ "effective_tld_names.dat" ];
  });

  iolib_merged = super.iolib_merged.overrideAttrs (oa: {
    propagatedBuildInputs = oa.propagatedBuildInputs ++ [ pkgs.libfixposix ];
  });

  # lisp-namespace = super.lisp-namespace.overrideAttrs (oa: {
  #   extraFiles = [ "namespace.lisp" ];
  # });

  trivial-mimes = super.trivial-mimes.overrideAttrs (oa: {
    extraFiles = [ "mime.types" ];
  });

  trivial-with-current-source-form =
    super.trivial-with-current-source-form.overrideAttrs (oa: {
      extraFiles = [ "version-string.sexp" ];
    });

})
