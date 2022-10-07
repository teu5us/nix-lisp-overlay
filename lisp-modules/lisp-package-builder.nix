{ stdenv
, scope
, pkgs
, lib
, compiler
, asdf
, runCommand
, buildSrc
, releases
, setJavaClassPath }:

args@{ pname
, version ? "unknown"
, name ? "${compiler.pname}-${compiler.version}_${pname}-${version}"
, src ? null
, release ? null
, providedSystems
, systemFiles
, extraFiles ? []
, lispInputs ? []
, nativeBuildInputs ? []
, buildInputs ? []
, propagatedBuildInputs ? []
, patches ? []
, ...}:

# assert src != null || release != null;

let
  asdfHook = import ./setup-hook.nix runCommand;
in
# here we pass a function to support proper overriding as per the nixpkgs manual
stdenv.mkDerivation (final: {
  inherit pname version name compiler systemFiles providedSystems extraFiles propagatedBuildInputs patches;

  # source needs to be unpacked for go-to-definition to work
  src = buildSrc args;

  # check for strings if we build from generated set
  lispInputs = map (v: if lib.isString v then scope.${v} else v) lispInputs;

  buildInputs = buildInputs
    ++ [ compiler asdfHook ]
    ++ (lib.optional (compiler.pname == "abcl") setJavaClassPath);

    # ${if lib.elem compiler.pname ["sbcl" "ccl"] #   then "(require :asdf)" #   else "(load \"${asdf}/lib/common-lisp/asdf/build/asdf.lisp\")"}
  buildPhase = with builtins; ''
    ### build in $out, so that lisps don't try to recompile dependencies
    ### see ASDF_OUTPUT_TRANSLATIONS
    output="$out/lib/common-lisp/${pname}"
    mkdir -p "$output"

    ## see ./setup-hook.sh
    copyFilesPreservingDirs "$output" "${toString final.systemFiles} version.sexp ${toString final.extraFiles}"
    #cp -r ./. $out/lib/common-lisp/${pname}

    ## see ./setup-hook.sh
    ## here we set XDG_CONFIG_DIRS, LD_LIBRARY_PATH, CPATH and PATH
    buildPathsForLisp "${toString final.lispInputs}" \
      "${toString final.buildInputs}" \
      "${toString final.propagatedBuildInputs}"
    export CL_SOURCE_REGISTRY="$CL_SOURCE_REGISTRY:$out//"
    export ASDF_OUTPUT_TRANSLATIONS="$ASDF_OUTPUT_TRANSLATIONS:$out/:$out/"
    export HOME=$out

    ### reset all timestamps before build
    find $out/ -name \*.\* -print | xargs -n1 touch -m --date=@0

    ${compiler}/bin/${compiler.pname} <<EOF

      (load "${asdf}/lib/common-lisp/asdf/build/asdf.lisp")

      (handler-case
          (progn
            (dolist (s '(${toString final.providedSystems}))
              (asdf:find-system s))
            (dolist (s '(${toString final.providedSystems}))
              (asdf:load-system s)))
        (error (c)
          (princ c)
          ;; remove $out if any error occurs
          (uiop:delete-directory-tree #p"$out/" :validate t)
          (uiop:quit 1)))
    EOF
  '';

  installPhase = with builtins; ''
    ### propagate lisp dependencies
    ## list immediate dependencies
    mkdir -p $out/nix-support
    printWords ${toString final.lispInputs} > $out/nix-support/lisp-inputs
    ## list propagated dependencies
    printWords ${toString final.propagatedBuildInputs} > $out/nix-support/propagated-build-inputs

    ## write all dependencies as configs,
    ## so we don't clutter CL_SOURCE_REGISTRY and ASDF_OUTPUT_TRANSLATIONS
    mkdir -p $out/share/common-lisp/{source-registry.conf.d,asdf-output-translations.conf.d}
    outputLispConfigs "$out ${toString final.lispInputs}"

    ## remove unneeded files
    rm -rf $out/.cache
  '';

  dontConfigure = true;
})
