{ buildLispPackage, fetchgit }:

buildLispPackage {
  pname = "ubiquitous";
  version = "2.0.0";
  src = with builtins; fetchgit (fromJSON (readFile ./source.json));
  providedSystems = [ "ubiquitous" ];
}
