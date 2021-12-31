pkgs: lispCompiler:

with pkgs;

let
  scope = lib.customisation.makeScope newScope (self: with self; {

    callPackage = self.callPackage;

    compiler = lispCompiler;

    withPackages = import ./wrap-lisp.nix pkgs scope compiler;

    buildLispPackage = import ./lisp-package-builder.nix
      pkgs compiler;

    alexandria = buildLispPackage {
      pname = "alexandria";
      version = "1.0.1";
      src = fetchgit {
        url = "https://gitlab.common-lisp.net/alexandria/alexandria.git";
        rev = "a67c3a6cc99d5d5180ce70985c04ddd91026104b";
        sha256 = "0q0ygiiql8gpap7g577shaibwgjcgw46i7j8mi4nd2np29z8kbca";
      };
    };
  });
in scope
