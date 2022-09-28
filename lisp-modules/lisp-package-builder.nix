{ stdenv
, lib
, compiler
, asdf
, runCommand
, setJavaClassPath }:

{ pname
, version ? "NIL"
, name ? "${pname}-${version}_${compiler.pname}-${compiler.version}"
, src
, providedSystems ? [ pname ]
, lispInputs ? []
, nativeBuildInputs ? []
, buildInputs ? []
, propagatedBuildInputs ? []
, sourceRoot ? "."
, includedFiles ? []
, patches ? []
, ...}:

stdenv.mkDerivation (final: let
  asdfHook = import ./setup-hook.nix runCommand;
in
  {
  inherit pname version name src compiler lispInputs propagatedBuildInputs patches;

  buildInputs =
    buildInputs
    ++ [ compiler asdfHook ]
    ++ (lib.optional (lib.all (el: el != compiler.pname) ["sbcl" "ccl"]) asdf)
    ++ (lib.optional (compiler.pname == "abcl") setJavaClassPath);

  buildPhase = with builtins; ''
    runHook preBuild
    # see ./setup-hook.sh
    buildPathsForLisp "${toString final.lispInputs}" "${toString final.buildInputs}" "${toString final.propagatedBuildInputs}"
    export CL_SOURCE_REGISTRY="$CL_SOURCE_REGISTRY:$src//"
    export ASDF_OUTPUT_TRANSLATIONS="$ASDF_OUTPUT_TRANSLATIONS:$src/:$(pwd)/"
    echo CL_SOURCE_REGISTRY $CL_SOURCE_REGISTRY
    echo ASDF_OUTPUT_TRANSLATIONS $ASDF_OUTPUT_TRANSLATIONS
    echo LD_LIBRARY_PATH $LD_LIBRARY_PATH
    export HOME=$(pwd)
    ${compiler}/bin/${compiler.pname} <<EOF
      ${if lib.elem compiler.pname ["sbcl" "ccl"]
        then "(require :asdf)"
        else "(load \"${asdf}/lib/common-lisp/asdf/build/asdf.lisp\")"}

      (handler-case
        (dolist (s '(${lib.concatStringsSep " " providedSystems}))
          ;; (asdf:compile-system s)
          (asdf:load-system s))
        (error (c)
          (princ c)
          (uiop:quit 1)))
    EOF
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    output="$out/lib/common-lisp/${pname}"
    mkdir -p "$output"
    cp -r * "$output"/
    mkdir -p $out/nix-support
    printWords ${builtins.toString final.lispInputs} > $out/nix-support/lisp-inputs
    runHook postInstall
  '';

  dontConfigure = true;
})
