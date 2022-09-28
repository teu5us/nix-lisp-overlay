{ buildLispPackage, fetchgit }:

buildLispPackage {
  pname = "cl-json";
  version = "0.5.0";
  src = with builtins; fetchgit (fromJSON (readFile ./source.json));
}
