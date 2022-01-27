{ scope }:

inputs:

with builtins;

let
  pnames = attrNames scope;
  required = filter (pname:
    let
      package = scope.${pname};
    in
    if (isAttrs package) && (hasAttr "providedSystems" package)
      then
        any (input:
          elem input package.providedSystems
        ) inputs
      else
        false
  ) pnames;
  requiredPackages = map (pname: getAttr pname scope) required;
  requiredPackagesSystems =
    concatMap (package: package.providedSystems) requiredPackages;
in
assert all (input: elem input requiredPackagesSystems) inputs;
requiredPackages
