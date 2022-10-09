{ lib, stdenv, makeWrapper, compiler, runCommand, pkg-config, scope }:

f:

{ extras ? [] }:

let
  asdf = scope.asdf;
  lispInputs = map (input: if lib.isString input then scope.${input} else input) (f scope);
  asdfHook = import ./setup-hook.nix runCommand;
in
stdenv.mkDerivation {
  name = "${compiler.name}-with-packages";
  nativeBuildInputs = [ makeWrapper pkg-config ];
  buildInputs = [ compiler asdfHook ] ++ extras;
  src = null;
  phases = [ "buildPhase" "installPhase" ];
      # --prefix PATH : "$PATH" \
  buildPhase = ''
    buildPathsForLisp "${toString lispInputs}" "${toString extras}" ""
    makeWrapper ${compiler}/bin/${compiler.pname} ./${compiler.pname} \
      --prefix XDG_CONFIG_DIRS : "$XDG_CONFIG_DIRS" \
      --prefix LD_LIBRARY_PATH : "$LD_LIBRARY_PATH" \
      --prefix CPATH : "$CPATH" \
      --prefix PKG_CONFIG_PATH : "$PKG_CONFIG_PATH" \
      --add-flags "--load" --add-flags "${asdf}/lib/common-lisp/asdf/build/asdf.lisp"
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp ${compiler.pname} $out/bin
  '';
}
