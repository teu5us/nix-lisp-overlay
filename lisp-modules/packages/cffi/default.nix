{ buildLispPackage, fetchgit, alexandria, trivial-features, babel, cl-ppcre, cl-json }:

buildLispPackage {
  pname = "cffi";
  src = with builtins; fetchgit (fromJSON (readFile ./source.json));
  lispInputs = [ alexandria trivial-features babel cl-ppcre cl-json ];
  providedSystems = [
    "cffi" "cffi/c2ffi" "cffi/c2ffi-generator" "cffi-grovel" "cffi-libffi" "cffi-toolchain"
  ];
}
