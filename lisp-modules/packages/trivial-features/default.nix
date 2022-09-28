{ buildLispPackage, fetchgit }:

buildLispPackage {
  pname = "trivial-features";
  src = with builtins; fetchgit (fromJSON (readFile ./source.json));
}
