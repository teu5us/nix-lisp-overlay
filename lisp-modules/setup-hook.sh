# This setup hook adds every propagated lisp system to CL_SOURCE_REGISTRY

buildAsdfPath () {
    declare -A lispPathsSeen=()
    for system in @lispInputs@; do
        _addToAsdfPath $system
    done
}

_addToAsdfPath ()  {
    local system="$1"
    if [ -v lispPathsSeen[$system] ]; then
        return
    else
        lispPathsSeen[$system]=1
        local path="$system/lib/common-lisp//"
        if [ -d "$path" ]; then
            addToSearchPath "CL_SOURCE_REGISTRY" "$path"
            local prop="$system/nix-support/propagated-build-inputs"
            if [ -e "$prop" ]; then
                local new_system
                for new_system in $(cat $prop); do
                    _addToAsdfPath "$new_system"
                done
            fi
        fi
    fi
}

addEnvHooks "$hostOffset" buildAsdfPath
