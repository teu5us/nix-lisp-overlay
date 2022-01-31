{ lib, scope }:

inputs:

with builtins;

let
  required = attrValues
    (lib.filterAttrs
      (n: v:
        if
          (lib.isDerivation v) && (hasAttr "providedSystems" v)
        then
          any (input:
            elem input v.providedSystems
          ) inputs
        else
          false)
      scope);
  requiredSystems = concatMap (p: p.providedSystems) required;
  inputsFound = lib.zipLists inputs
    (map (input: elem input requiredSystems) inputs);
in
if all (input: input.snd) inputsFound
  then
    required
  else
    let
      notFound = filter (input: !input.snd) inputsFound;
    in
      throw ''
        Packages were not found for systems:
          ${lib.concatStringsSep ", " (map (input: "\"" + input.fst + "\"") notFound)}
      ''
