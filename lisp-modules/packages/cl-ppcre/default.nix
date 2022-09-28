{ buildLispPackage, fetchgit }:

buildLispPackage {
  pname = "cl-ppcre";
  version = "2.1.1";
  src = with builtins; fetchgit (fromJSON (readFile ./source.json));
}
