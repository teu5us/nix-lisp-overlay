{ buildLispPackage, fetchgit }:

buildLispPackage {
  pname = "alexandria";
  version = "1.0.1";
  providedSystems = [ "alexandria" ];
  src = with builtins; fetchgit (fromJSON (readFile ./source.json));
}
