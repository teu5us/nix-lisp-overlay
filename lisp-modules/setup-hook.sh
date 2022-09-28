# This setup hook adds every propagated lisp system to CL_SOURCE_REGISTRY and ASDF_OUTPUT_TRANSLATIONS

addToSearchPathWithCustomDelimiter_unsafe () {
    local delimiter="$1"
    local varName="$2"
    local dir="$3"
    if [[ -d "$dir" && "${!varName:+${delimiter}${!varName}${delimiter}}" \
          != *"${delimiter}${dir}${delimiter}"* ]]; then
        export "${varName}=${!varName:+${!varName}${delimiter}}${dir}${delimiter}${dir}"
    fi
}

buildPathsForLisp () {
    local lispInputs="$1"
    local buildInputs="$2"
    local propagatedBuildInputs="$3"
    declare -A lispPathsSeen=()
    declare -A extPathsSeen=()
    declare -A aotFrom=()
    declare -A aotTo=()
    for system in $lispInputs; do
        _addToLispPath $system
    done

    for package in $lispInputs $buildInputs $propagatedBuildInputs; do
        _addToExternalPath $package
    done
}

_addToLispPath ()  {
    local system="$1"
    if [ -v lispPathsSeen[$system] ]; then
        return
    else
        lispPathsSeen[$system]=1
        local lisp_path="$system/lib/common-lisp"
        if [ -d "$lisp_path" ]; then
            addToSearchPath "CL_SOURCE_REGISTRY" "$lisp_path//"
            addToSearchPathWithCustomDelimiter_unsafe ":" "ASDF_OUTPUT_TRANSLATIONS" "$lisp_path/"
            local prop="$system/nix-support/lisp-inputs"
            if [ -e "$prop" ]; then
                local new_system
                for new_system in $(cat $prop); do
                    _addToLispPath "$new_system"
                done
            fi
        fi
    fi
}

_addToExternalPath () {
    local package="$1"
    if [ -v extPathsSeen[$package] ]; then
        return
    else
        extPathsSeen[$package]=1
        local bin_path="$package/bin"
        local lib_path="$package/lib"
        local inc_path="$package/include"
        if [ -d "$lib_path" ]; then
            addToSearchPath "LD_LIBRARY_PATH" "$lib_path"
        fi
        if [ -d "$bin_path" ]; then
            addToSearchPath "PATH_FOR_LISP" "$bin_path"
        fi
        if [ -d "$inc_path" ]; then
            addToSearchPath "CPATH" "$inc_path"
        fi
        local prop="$package/nix-support/propagated-build-inputs"
        if [ -e "$prop" ]; then
            local new_package
            for new_package in $(cat $prop); do
                _addToExternalPath "$new_package"
            done
        fi
    fi
}

# NOTE: we call buildLispPathsForLisp manually in buildPhase to avoid recursion
# addEnvHooks "$targetOffset" buildPathsForLisp
