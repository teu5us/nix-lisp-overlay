{ stdenv
, lib
, scope
, compiler
, asdf
, resolveLispInputs
, runCommand
, setJavaClassPath }:

{ pname
, version
, name ? "${pname}-${version}_${compiler.pname}-${compiler.version}"
, providedSystems ? [ pname ]
, src
, lispInputs ? []
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
  inherit pname version name src compiler providedSystems;

  buildInputs =
    buildInputs
    ++ [ compiler asdf asdfHook ]
    ++ (lib.optional (compiler.pname == "abcl") setJavaClassPath);

  propagatedBuildInputs = propagatedBuildInputs ++ resolvedLispInputs;

  buildPhase = ''
    export CPATH="$CPATH:${lib.makeSearchPath "include" buildInputs}"
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
