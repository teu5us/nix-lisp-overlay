{ lib, stdenv, makeWrapper, compiler, runCommand, pkg-config, scope, confBuilders }:

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
      # --add-flags "--eval" --add-flags "'(asdf:initialize-source-registry #p\"${confBuilders.buildSourceRegistry lispInputs}\")'" \
      # --add-flags "--eval" --add-flags "'(asdf:initialize-output-translations #p\"${confBuilders.buildOutputTranslations lispInputs}\")'"
      # --prefix PATH : "$PATH" \
  buildPhase = ''
    buildPathsForLisp "${toString lispInputs}" "${toString extras}" ""
    makeWrapper ${compiler}/bin/${compiler.pname} ./${compiler.pname} \
      --set XDG_CONFIG_DIRS "$XDG_CONFIG_DIRS" \
      --set LD_LIBRARY_PATH "$LD_LIBRARY_PATH" \
      --set CPATH "$CPATH" \
      --set PKG_CONFIG_PATH "$PKG_CONFIG_PATH" \
      --add-flags "--load" --add-flags "${asdf}/lib/common-lisp/asdf/build/asdf.lisp"
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp ${compiler.pname} $out/bin
  '';
}
