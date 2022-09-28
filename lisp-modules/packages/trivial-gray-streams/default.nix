{ buildLispPackage, fetchgit }:

buildLispPackage {
  pname = "trivial-gray-streams";
  src = with builtins; fetchgit (fromJSON (readFile ./source.json));
}
