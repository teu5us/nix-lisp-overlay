{ lib, scope }:

inputs:

with builtins;

let
  required = lib.filterAttrs (n: v:
    if (isAttrs v) && (hasAttr "providedSystems" v)
      then
        any (input:
          elem input v.providedSystems
        ) inputs
      else
        false
  ) scope;
  requiredSystems = concatMap (p: p.providedSystems) (attrValues required);
in
assert all (input: elem input requiredSystems) inputs;
attrValues required
