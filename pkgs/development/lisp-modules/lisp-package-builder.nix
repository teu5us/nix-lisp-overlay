{ stdenv, lib, scope, compiler, asdf, resolveLispInputs, runCommand }:

{ pname
, version
, name ? "${pname}-${version}_${compiler.pname}-${compiler.version}"
, providedSystems ? [ pname ]
, src
, lispInputs ? []
, nativeBuildInputs ? []
, buildInputs ? []
, propagatedBuildInputs ? []
, sourceRoot ? "."
, includedFiles ? [],
...} @ attrs:

let
  resolvedLispInputs = resolveLispInputs lispInputs;
  asdfHookFun = import ./setup-hook.nix runCommand;
  asdfHook = asdfHookFun resolvedLispInputs;
in
stdenv.mkDerivation {
  inherit pname version name src compiler buildInputs providedSystems;

  nativeBuildInputs = nativeBuildInputs ++ [ compiler asdf asdfHook ];

  propagatedBuildInputs = propagatedBuildInputs ++ resolvedLispInputs;

  buildPhase = ''
    export CPATH="$CPATH:${lib.makeSearchPath "include" (nativeBuildInputs ++ buildInputs ++ propagatedBuildInputs)}"
    export ASDF_OUTPUT_TRANSLATIONS="$src:$(pwd):${builtins.storeDir}:${builtins.storeDir}"
    export CL_SOURCE_REGISTRY="$CL_SOURCE_REGISTRY:$(pwd)//"
    ${compiler}/bin/${compiler.pname} <<EOF
      (load "${asdf}/lib/common-lisp/asdf/build/asdf.lisp")
      (dolist (system '(${lib.concatStringsSep " " providedSystems}))
        (asdf:compile-system system)
        (asdf:load-system system))
    EOF
  '';

  installPhase = ''
    output="$out/lib/common-lisp/${pname}"
    mkdir -p "$output"
    cp -r * "$output"/
  '';

  dontConfigure = true;
}
