{ lib, scope }:

inputs:

with builtins;

let
  pnames = attrNames scope;
  required = filter (pname:
    if (isAttrs scope.${pname}) && (hasAttr "providedSystems" scope.${pname})
      then any (input:
        elem input scope.${pname}.providedSystems)
        inputs
      else false
  ) pnames;
in
map (pname: getAttr pname scope) required
