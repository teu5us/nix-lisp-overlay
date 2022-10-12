{ lib, stdenv, makeWrapper, compiler, runCommand, pkg-config, scope }:

packages:

let
  asdf = scope.asdf;
  lispInputs = map
    (input: if lib.isString input then scope.${input} else input)
    (packages scope);
  asdfHook = import ./setup-hook.nix runCommand;
in
stdenv.mkDerivation {
  inherit lispInputs;
  name = "${compiler.name}-with-packages";
  nativeBuildInputs = [ makeWrapper pkg-config ];
  buildInputs = [ compiler asdfHook ];
  src = null;
  phases = [ "buildPhase" "installPhase" ];
  buildPhase = ''
    makeWrapper ${compiler}/bin/${compiler.pname} ./${compiler.pname} \
      --prefix XDG_CONFIG_DIRS : "$out/share" \
      --prefix LD_LIBRARY_PATH : "$LD_LIBRARY_PATH" \
      --prefix CPATH : "$CPATH" \
      --prefix PKG_CONFIG_PATH : "$PKG_CONFIG_PATH" \
      --add-flags "--load" --add-flags "${asdf}/lib/common-lisp/asdf/build/asdf.lisp"
  '';
  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/common-lisp/source-registry.conf.d
    mkdir -p $out/share/common-lisp/asdf-output-translations.conf.d
    outputLispConfigs
    cp ${compiler.pname} $out/bin
  '';
}
