{ buildLispPackage, fetchgit, alexandria, trivial-features, babel }:

buildLispPackage {
  pname = "cffi";
  lname = "cffi";
  src = with builtins; fetchgit (fromJSON (readFile ./source.json));
  lispInputs = [ alexandria trivial-features babel ];
  asd = "cffi.asd";
  systemFiles = [ "src/cffi-sbcl.lisp" "src/package.lisp" "src/utils.lisp" "src/libraries.lisp" "src/early-types.lisp" "src/types.lisp" "src/enum.lisp" "src/strings.lisp" "src/structures.lisp" "src/functions.lisp" "src/foreign-vars.lisp" "src/features.lisp" "src/cffi-openmcl.lisp" "src/cffi-mcl.lisp" "src/cffi-sbcl.lisp" "src/cffi-cmucl.lisp" "src/cffi-scl.lisp" "src/cffi-clisp.lisp" "src/cffi-lispworks.lisp" "src/cffi-ecl.lisp" "src/cffi-allegro.lisp" "src/cffi-corman.lisp" "src/cffi-abcl.lisp" "src/cffi-mkcl.lisp" "src/cffi-clasp.lisp" ];
}
