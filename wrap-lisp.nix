pkgs: packageSet: compiler: f:

with pkgs;

let
  makeLispPath = import ./make-lisp-path.nix pkgs;
  packages = f packageSet;
in
symlinkJoin {
  name = "${compiler.name}-with-packages";
  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ asdf ];
  paths = [ compiler ];
  postBuild = ''
    wrapProgram $out/bin/${compiler.pname} \
      --set "CL_SOURCE_REGISTRY" "${makeLispPath packages}" \
      --add-flags "--load \"${asdf}/lib/common-lisp/asdf/build/asdf.lisp\""
  '';
}
