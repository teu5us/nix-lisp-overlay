{ pkgs, packageSet, compiler }:

f:

with pkgs;

let
  lispInputs = f packageSet;
  asdfHook = (pkgs.callPackage ./setup-hook.nix {}) lispInputs;
in
stdenv.mkDerivation {
  name = "${compiler.name}-with-packages";
  nativeBuildInputs = [ makeWrapper asdfHook ];
  buildInputs = [ asdf compiler ] ++ lispInputs;
  src = compiler;
  phases = [ "buildPhase" "installPhase" ];
  buildPhase = ''
    makeWrapper $src/bin/${compiler.pname} ./${compiler.pname} \
      --set "CL_SOURCE_REGISTRY" "$CL_SOURCE_REGISTRY" \
      --add-flags "--load \"${asdf}/lib/common-lisp/asdf/build/asdf.lisp\""
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp ${compiler.pname} $out/bin
  '';
}

# symlinkJoin {
#   name = "${compiler.name}-with-packages";
#   nativeBuildInputs = [ makeWrapper asdfHook ];
#   buildInputs = [ asdf ];
#   paths = [ compiler ];
#   postBuild = ''
#     wrapProgram $out/bin/${compiler.pname} \
#       --set "CL_SOURCE_REGISTRY" "$CL_SOURCE_REGISTRY" \
#       --add-flags "--load \"${asdf}/lib/common-lisp/asdf/build/asdf.lisp\""
#   '';
# }
