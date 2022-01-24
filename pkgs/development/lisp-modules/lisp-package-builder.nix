{ pkgs, compiler, asdf }:

{ pname
, version
, name ? "${pname}-${version}_${compiler.pname}-${compiler.version}"
, src
, lispInputs ? []
, nativeBuildInputs ? []
, buildInputs ? []
, propagatedBuildInputs ? []
, sourceRoot ? "."
, includedFiles ? [],
...} @ attrs:

let
  stdenv = pkgs.stdenv;
  lib = pkgs.lib;
  asdfHook = (pkgs.callPackage ./setup-hook.nix { }) lispInputs;
in
stdenv.mkDerivation {
  inherit pname version name src compiler buildInputs;

  nativeBuildInputs = nativeBuildInputs ++ [ compiler asdf asdfHook ];

  propagatedBuildInputs = propagatedBuildInputs ++ lispInputs;

  buildPhase = ''
    export CPATH="$CPATH:${lib.makeSearchPath "include" (nativeBuildInputs ++ buildInputs ++ propagatedBuildInputs)}"
    # export ASDF_OUTPUT_TRANSLATIONS="${builtins.storeDir}/:${builtins.storeDir}"
    export CL_SOURCE_REGISTRY="$CL_SOURCE_REGISTRY:$(pwd)//"
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
