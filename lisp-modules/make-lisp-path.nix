pkgs: ps:

let
  recurseIntoInputs = attr: p:
    if builtins.isAttrs p
    then
      (pkgs.lib.concatMap (p: recurseIntoInputs attr)
        (builtins.getAttr attr p)) ++ [p]
    else [p];
  pkgInputs = attr: p: pkgs.lib.unique (recurseIntoInputs attr p);
  collectPaths = ps:
    (map (p: "${p.outPath}/lib/common-lisp/${p.name}//")
      (pkgs.lib.concatMap (p: pkgInputs "lispInputs" p) ps));
in
pkgs.lib.concatStringsSep ":" (collectPaths ps)
