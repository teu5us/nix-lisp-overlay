{ lib, scope }:

inputs:

with builtins;

let
  required = attrValues
    (lib.filterAttrs
      (n: v:
        if
          (isAttrs v) && (hasAttr "providedSystems" v)
        then
          any (input:
            elem input v.providedSystems
          ) inputs
        else
          false)
      scope);
  requiredSystems = concatMap (p: p.providedSystems) required;
  allPackagesFound = all (input: elem input requiredSystems) inputs;
in
assert allPackagesFound;
required
