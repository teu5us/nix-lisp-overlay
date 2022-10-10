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
        lispPackages // {
          overlay = self: super: { inherit lispPackages; };
        }
    );
}
