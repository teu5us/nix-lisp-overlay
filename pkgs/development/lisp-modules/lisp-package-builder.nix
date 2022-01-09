{ pkgs, compiler, asdf }:

{ pname
, version
, name ? "${pname}-${version}_${compiler.pname}-${compiler.version}"
, src
, lispInputs ? []
, nativeBuildInputs ? []
, buildInputs ? []
, propagatedBuildInputs ? []
, preBuild ? ""
, sourceRoot ? "."
, includedFiles ? [] }:

let
  stdenv = pkgs.stdenv;
  lib = pkgs.lib;
  makeAsdPath = import ./make-lisp-path.nix pkgs;
  nbi = nativeBuildInputs ++ [ compiler asdf ];
in
stdenv.mkDerivation rec {
  inherit pname version name src compiler buildInputs propagatedBuildInputs lispInputs preBuild;

  nativeBuildInputs = nbi;

  buildPhase = ''
    export CPATH="$CPATH:${lib.makeSearchPath "include" (nativeBuildInputs ++ buildInputs ++ propagatedBuildInputs)}"
    export ASDF_OUTPUT_TRANSLATIONS="${builtins.storeDir}/:${builtins.storeDir}"
    export CL_SOURCE_REGISTRY="${makeAsdPath lispInputs}:$(pwd)//"
    ${compiler}/bin/${compiler.pname} \
      --load "${asdf}/lib/common-lisp/asdf/build/asdf.lisp" \
      --eval "(asdf:compile-system :${pname})" \
      --eval "(asdf:load-system :${pname})"
  '';

  installPhase = ''
    output="$out/lib/common-lisp/${name}"
    mkdir -p "$output"
    cp -r * "$output"/
  '';

  dontConfigure = true;
}
