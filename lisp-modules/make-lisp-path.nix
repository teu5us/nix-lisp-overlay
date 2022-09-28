lib: ps:

let
  packageToInputs = attr: p:
    [p] ++ map (p: packageToInputs attr p) (lib.getAttr attr p);

  collectInputs = attr: ps:
    (lib.filter lib.isDerivation
      (lib.flatten (map (p: packageToInputs attr p) ps)));

  inputs = lib.flip collectInputs ps;

  collectLispPaths = map (p: "${p.outPath}/lib/common-lisp/${p.pname}")
    (inputs "lispInputs");
in
{
  registry = lib.concatMapStringsSep ":" (s: "${s}//") collectLispPaths;

  outputsBuilder = lib.concatMapStringsSep ":" (s: "${s}:${s}") collectLispPaths;

  outputsLisp = lib.concatStringsSep "::" collectLispPaths + "::";

  ld = lib.makeLibraryPath (inputs "propagatedBuildInputs");

  cpath = lib.makeSearchPath "include" (inputs "propagatedBuildInputs");
}
