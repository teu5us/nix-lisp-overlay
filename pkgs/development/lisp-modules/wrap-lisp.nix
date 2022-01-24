{ pkgs, packageSet, compiler }:

f:

with pkgs;

let
  lispInputs = f packageSet;
  asdfHook = (pkgs.callPackage ./setup-hook.nix {}) lispInputs;
in
symlinkJoin {
  name = "${compiler.name}-with-packages";
  nativeBuildInputs = [ makeWrapper asdfHook ];
  buildInputs = [ asdf ];
  paths = [ compiler ];
  postBuild = ''
    wrapProgram $out/bin/${compiler.pname} \
      --set "CL_SOURCE_REGISTRY" "$CL_SOURCE_REGISTRY" \
      --add-flags "--load \"${asdf}/lib/common-lisp/asdf/build/asdf.lisp\""
  '';
}
