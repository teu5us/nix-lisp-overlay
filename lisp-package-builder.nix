pkgs: compiler:

with pkgs;

{ pname
, version
, src
, lispDependencies ? []
, nativeBuildInputs ? []
, buildInputs ? []
, propagatedBuildInputs ? [] }:

let
  makeLispPath = import ./make-lisp-path.nix pkgs;
  nbi = nativeBuildInputs;
  pbi = propagatedBuildInputs;
in
stdenv.mkDerivation rec {
  inherit pname version src compiler buildInputs;

  name = "${pname}-${version}_${compiler.pname}-${compiler.version}";

  nativeBuildInputs = nbi ++ [ compiler asdf ];
  propagatedBuildInputs = pbi ++ lispDependencies;

  CL_SOURCE_REGISTRY = makeLispPath lispDependencies;

  LD_LIBRARY_PATH = lib.makeLibraryPath
    (nativeBuildInputs ++ buildInputs ++ propagatedBuildInputs);

  CPATH = lib.makeSearchPath "lib/include"
    (nativeBuildInputs ++ buildInputs);

  PATH = lib.makeBinPath (nativeBuildInputs ++ buildInputs);

  buildPhase = ''
    export ASDF_OUTPUT_TRANSLATIONS="$(pwd)/:$(pwd)/translations/"
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
}
