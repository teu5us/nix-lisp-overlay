# This setup hook adds every propagated lisp system to CL_SOURCE_REGISTRY

buildAsdfPath ()  {
    declare -A lispPathsSeen=()
    for system in @lispInputs@; do
        local path="$system/lib/common-lisp//"
        if [ -d "$path" ]; then
            lispPathsSeen[$path]=1
            addToSearchPath "CL_SOURCE_REGISTRY" "$path"
            local prop="$system/nix-support/propagated-build-inputs"
            if [ -e "$prop" ]; then
                local new_path
                for new_system in $(cat $prop); do
                    addToAsdfPath "$new_system"
                done
            fi
        fi
    done
}

addEnvHooks "$hostOffset" buildAsdfPath
