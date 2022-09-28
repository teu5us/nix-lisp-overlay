{ lib, stdenv, makeWrapper, compiler, runCommand, pkg-config, scope }:

f:

{ extras ? [] }:

let
  asdf = scope.asdf;
  lispInputs = f scope;
  asdfHook = import ./setup-hook.nix runCommand;
in
stdenv.mkDerivation {
  name = "${compiler.name}-with-packages";
  nativeBuildInputs = [ makeWrapper pkg-config ];
  buildInputs = [ compiler asdfHook ] ++ extras;
  src = null;
  phases = [ "buildPhase" "installPhase" ];
  buildPhase = ''
    buildPathsForLisp "${toString lispInputs}" "${toString extras}"
    makeWrapper ${compiler}/bin/${compiler.pname} ./${compiler.pname} \
      --set "CL_SOURCE_REGISTRY" "$CL_SOURCE_REGISTRY" \
      --set ASDF_OUTPUT_TRANSLATIONS "$ASDF_OUTPUT_TRANSLATIONS" \
      --set LD_LIBRARY_PATH "$LD_LIBRARY_PATH" \
      --set CPATH "$CPATH" \
      --set PKG_CONFIG_PATH "$PKG_CONFIG_PATH" \
      --set PATH "$PATH_FOR_LISP" \
      --add-flags ${if lib.elem compiler.pname ["sbcl" "ccl"]
                    then "--eval --add-flags \"'(require :asdf)'\""
                    else "--load \"${asdf}/lib/common-lisp/asdf/build/asdf.lisp\""}
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp ${compiler.pname} $out/bin
  '';
}
