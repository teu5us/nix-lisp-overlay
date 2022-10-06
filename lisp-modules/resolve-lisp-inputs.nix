{ lib, scope }:

lispInputs:

with builtins;

let
  filterInputs = inputs: lib.filter
    (input: !elem input (provided ++ ["asdf" "uiop"])) inputs;
  # scope' = lib.filter (input: !elem input inputs) (attrValues scope);
  scope' = attrValues scope;
  required = lib.filter (p:
    if (lib.isDerivation p) && (p ? "providedSystems")
    then any (input: elem input p.providedSystems) (filterInputs lispInputs)
    else false
  ) scope';
  # required = attrValues
  #   (lib.filterAttrs
  #     (n: v:
  #       if
  #         (lib.isDerivation v) && (hasAttr "providedSystems" v)
  #       then
  #         any (input:
  #           elem input v.providedSystems
  #         ) newInputs
  #       else
  #         false)
  #     scope);
  # requiredSystems = concatMap (p: p.providedSystems) required;
  # inputsFound = lib.zipLists newInputs
  #   (map (input: elem input requiredSystems) newInputs);
in
map (p: p.src) required
# if all (input: input.snd) inputsFound
#   then
#     lib.remove scope."${pname}" required
#   else
#     let
#       notFound = filter (input: !input.snd) inputsFound;
#     in
#       throw ''
#         Packages were not found for systems:
#           ${lib.concatStringsSep ", " (map (input: "\"" + input.fst + "\"") notFound)}
# #       ''
