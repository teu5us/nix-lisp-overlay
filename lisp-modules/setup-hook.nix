runCommand:

let
  hook = ./setup-hook.sh;
in
runCommand "asdf-setup-hook.sh" {} ''
    cp ${hook} hook.sh
    substituteAllInPlace hook.sh
    mv hook.sh $out
''
