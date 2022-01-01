pkgs: ps:

pkgs.lib.concatStringsSep ":"
  (map (p: "${p.outPath}/lib/common-lisp/${p.name}//") ps)
