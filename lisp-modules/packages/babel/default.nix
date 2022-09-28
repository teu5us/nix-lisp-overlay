{ buildLispPackage, fetchgit, alexandria, trivial-features, trivial-gray-streams }:

buildLispPackage {
  pname = "babel";
  src = with builtins; fetchgit (fromJSON (readFile ./source.json));
  lispInputs = [ alexandria trivial-features trivial-gray-streams ];
  providedSystems = [ "babel" "babel-streams" ];
}
