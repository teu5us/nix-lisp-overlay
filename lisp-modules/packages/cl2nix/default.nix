{ buildLispPackage, ubiquitous }:

buildLispPackage {
  pname = "cl2nix";
  version = "dev";
  src = ./.;
  providedSystems = [ "cl2nix" ];
  lispInputs = [ ubiquitous ];
}
