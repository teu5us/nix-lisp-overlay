{
  description = "Common Lisp overlay";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lispPackages = import ./default.nix { inherit pkgs; };
      in
        {
          packages = lispPackages // {
            nyxt-gtk = lispPackages.sbclPackages.nyxt-gtk;
          };
          overlay = self: super: { inherit lispPackages; };
        }
    );
}
