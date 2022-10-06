{ pkgs, lib }:

scope:

scope.overrideScope' (self: super: {

  cffi = super.cffi.overrideAttrs (oa: {
    extraFiles = [
      "src/cffi-openmcl.lisp" "src/cffi-mcl.lisp" "src/cffi-sbcl.lisp"
      "src/cffi-cmucl.lisp" "src/cffi-scl.lisp" "src/cffi-clisp.lisp"
      "src/cffi-lispworks.lisp" "src/cffi-ecl.lisp" "src/cffi-allegro.lisp"
      "src/cffi-corman.lisp" "src/cffi-abcl.lisp" "src/cffi-mkcl.lisp"
      "src/cffi-clasp.lisp"
    ];
  });

  bordeaux-threads = super.bordeaux-threads.overrideAttrs (oa: {
    extraFiles = [  "src/impl-clozure.lisp" ];
  });

  cl-libuv = super.cl-libuv.overrideAttrs (oa: {
    lispInputs = oa.lispInputs ++ [ self.cffi-grovel ];
    propagatedBuildInputs = oa.propagatedBuildInputs ++ [ pkgs.libuv ];
  });

  cl-async = super.cl-async.overrideAttrs (oa: {
    providedSystems = [ "cl-async" ];
  });

  static-vectors = super.static-vectors.overrideAttrs (oa: {
    extraFiles = [ "version.sexp" "src/impl-clozure.lisp"  ];
  });

  trivial-features = super.trivial-features.overrideAttrs (oa: {
    extraFiles = [
      "src/tf-allegro.lisp" "src/tf-clisp.lisp" "src/tf-cmucl.lisp"
      "src/tf-corman.lisp" "src/tf-ecl.lisp" "src/tf-genera.lisp"
      "src/tf-lispworks.lisp" "src/tf-openmcl.lisp" "src/tf-mcl.lisp"
      "src/tf-mkcl.lisp" "src/tf-sbcl.lisp" "src/tf-scl.lisp"
      "src/tf-abcl.lisp" "src/tf-xcl.lisp" "src/tf-mocl.lisp"
      "src/tf-clasp.lisp" "src/tf-mezzano.lisp"
    ];
  });

})
