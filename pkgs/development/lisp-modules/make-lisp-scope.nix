{ pkgs }:

compiler:

let
  lib = pkgs.lib;
  stdenv = pkgs.stdenv;
  fetchgit = pkgs.fetchgit;
  newScope = pkgs.newScope;
  scope = lib.customisation.makeScope newScope (self: with self; {
    inherit compiler;

    resolveLispInputs = callPackage ./resolve-lisp-inputs.nix
      { inherit scope lib; };

    lispWithPackages = callPackage ./wrap-lisp.nix
      { inherit pkgs compiler resolveLispInputs; };

    buildLispPackage = callPackage ./lisp-package-builder.nix
      { inherit stdenv lib compiler asdf resolveLispInputs scope; };

    asdf = pkgs.asdf;

    uiop = pkgs.asdf;

    alexandria = buildLispPackage {
      pname = "alexandria";
      version = "1.0.1";
      src = fetchgit {
        url = "https://gitlab.common-lisp.net/alexandria/alexandria.git";
        rev = "a67c3a6cc99d5d5180ce70985c04ddd91026104b";
        sha256 = "0q0ygiiql8gpap7g577shaibwgjcgw46i7j8mi4nd2np29z8kbca";
      };
    };

    trivial-with-current-source-form = buildLispPackage {
      pname = "trivial-with-current-source-form";
      version = "0.1.0";
      src = fetchgit {
        url = "https://github.com/scymtym/trivial-with-current-source-form.git";
        sha256 = "1114iibrds8rvwn4zrqnmvm8mvbgdzbrka53dxs1q61ajv44x8i0";
        rev = "3898e09f8047ef89113df265574ae8de8afa31ac";
      };
      lispInputs = [ "alexandria" ];
    };
  });
in scope
