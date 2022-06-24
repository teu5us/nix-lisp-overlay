{ lib, stdenv, newScope, asdf, runCommand }:

compiler:

let
  list_NonRecursive = t:
    with lib;
    dir: mapAttrsToList (name: type: name)
      (filterAttrs (name: type: type == t)
        (builtins.readDir dir));

  listDirsNonRecursive = dir:
    map (name: dir + ("/" + name)) (list_NonRecursive "directory" dir);

  listFilesNonRecursive = dir: list_NonRecursive "regular" dir;

  filename = path: lib.last (lib.splitString "/" (toString path));

  scope = lib.customisation.makeScope newScope (self: with self; {
    inherit compiler asdf;

    callPackage = self.callPackage;

    resolveLispInputs = callPackage ./resolve-lisp-inputs.nix
      { inherit lib scope; };

    lispWithPackages = callPackage ./wrap-lisp.nix
      { inherit compiler resolveLispInputs runCommand; };

    buildLispPackage = callPackage ./lisp-package-builder.nix
      { inherit stdenv lib compiler asdf resolveLispInputs scope; };

    setFromDir = dir:
      let
        dirs = listDirsNonRecursive dir;
        dirnames = map filename dirs;
        overlaps = lib.any
          (name: builtins.elem name (lib.attrNames self))
          dirnames;
        set = lib.listToAttrs
          (map (dir':
            {
              name = filename dir';
              value = {
                path = dir';
                files = listFilesNonRecursive dir';
              };
            }
          ) dirs);
        buildPackageSet =
          lib.filterAttrs (name: value: value != null)
            (
              lib.mapAttrs (name: value:
                let
                  package = if builtins.elem "default.nix" value.files
                            then callPackage value.path {}
                            else null;
                  fixup = if builtins.elem "fixup.nix" value.files
                          then callPackage
                            (value.path + "/fixup.nix") {}
                          else null;
                  applyFixup = package: if fixup != null
                                        then fixup package
                                        else package;
                in
                  if package != null then applyFixup package else null
              ) set
            );
      in
        if overlaps
        then throw "Common Lisp package names should not overlap with the base set."
        else buildPackageSet;

    uiop = asdf;
  });
in scope // (scope.setFromDir ./packages)
