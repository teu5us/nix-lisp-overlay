# This setup hook adds every propagated lisp system to CL_SOURCE_REGISTRY and ASDF_OUTPUT_TRANSLATIONS

addToSearchPathWithCustomDelimiter_unsafe () {
    local delimiter="$1"
    local varName="$2"
    local dir="$3"
    # local mapping="((\"$dir/\" :**/) (\"$dir/\" :**/))"
    # if [[ -d "$dir" && "${!varName:+${delimiter}${!varName}${delimiter}}" \
    #       != *"${delimiter}${dir}${delimiter}"* ]]; then
    #     export "${varName}=${!varName:+${!varName}${delimiter}}${mapping}"
    # fi
    if [[ -d "$dir" && "${!varName:+${delimiter}${!varName}${delimiter}}" \
          != *"${delimiter}${dir}${delimiter}"* ]]; then
        export "${varName}=${!varName:+${!varName}${delimiter}}${dir}${delimiter}${dir}"
    fi
}

copyFilesPreservingDirs () {
    local to="$1"
    local files="$2"
    for file in ${files[@]}; do
        # local implFiles=`locateImplementationFilesInDir "$filedir"`
        if [ -f "$file" ]; then
            local filedir=`dirname $file`
            mkdir -p "$to"/"$filedir"
            cp -p "$file" "$to"/"$file"
        fi
        if [ -d "$file" ]; then
            mkdir -p "$to"/"$file"
            cp -p -r "$file/." "$to"/"$file"
        fi
        for f in ${implFiles[@]}; do
            cp -p -r "$f" "$to"/"$f"
        done
    done
}

# locateImplementationFilesInDir () {
#     local dir="$1"
#     declare -a implementationList=(abcl \
#                                        acl \
#                                        allegro \
#                                        ccl \
#                                        clasp \
#                                        clisp \
#                                        clozure \
#                                        cmu \
#                                        cmucl \
#                                        corman \
#                                        cormanlisp \
#                                        ecl \
#                                        gcl \
#                                        genera \
#                                        mezzano \
#                                        lispworks \
#                                        lispworks-personal-edition \
#                                        lw \
#                                        lwpe \
#                                        mcl \
#                                        mkcl \
#                                        openmcl \
#                                        sbcl \
#                                        scl \
#                                        smbx \
#                                        symbolics \
#                                        xcl )
#     declare -a implementationFiles=()
#     for impl in ${implementationList[@]}; do
#         if [ -d "$dir" ]; then
#             local file=`find "$dir" -maxdepth 1 -name "*$impl*"`
#             [ -f "$file" ] && implementationFiles+=("$file")
#         fi
#     done
#     echo ${implementationFiles[@]}
# }

outputLispConfigs () {
    local lispInputs="$1"
    declare -A lispPathsSeen=()
    for system in $lispInputs; do
        _outputLispConfigs $system
    done
}

_outputLispConfigs ()  {
    local system="$1"
    if [ -v lispPathsSeen[$system] ]; then
        return
    else
        lispPathsSeen[$system]=1
        local lisp_path="$system"
        if [ -d "$lisp_path" ]; then
            echo "(:tree \"$lisp_path\")" > "$out/share/common-lisp/source-registry.conf.d/$(stripHash $lisp_path).conf"
            echo "(\"$lisp_path\" t)" > "$out/share/common-lisp/asdf-output-translations.conf.d/$(stripHash $lisp_path).conf"
            local prop="$system/nix-support/lisp-inputs"
            if [ -e "$prop" ]; then
                local new_system
                for new_system in $(cat $prop); do
                    _outputLispConfigs "$new_system"
                done
            fi
        fi
    fi
}

buildPathsForLisp () {
    local lispInputs="$1"
    local buildInputs="$2"
    local propagatedBuildInputs="$3"
    declare -A lispPathsSeen=()
    declare -A extPathsSeen=()
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
        local lisp_path="$system"
        if [ -d "$lisp_path" ]; then
            addToSearchPath "XDG_CONFIG_DIRS" "$lisp_path/share"
            # addToSearchPath "CL_SOURCE_REGISTRY" "$lisp_path//"
            # addToSearchPathWithCustomDelimiter_unsafe ":" "ASDF_OUTPUT_TRANSLATIONS" "$lisp_path/"
            # local prop="$system/nix-support/lisp-inputs"
            # if [ -e "$prop" ]; then
            #     local new_system
            #     for new_system in $(cat $prop); do
            #         _addToLispPath "$new_system"
            #     done
            # fi
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
            if [ ! -d "$lib_path/common-lisp" ]; then
                addToSearchPath "LD_LIBRARY_PATH" "$lib_path"
            fi
        fi
        if [ -d "$bin_path" ]; then
            addToSearchPath "PATH" "$bin_path"
        fi
        if [ -d "$inc_path" ]; then
            addToSearchPath "CPATH" "$inc_path"
        fi
        local lisp="$system/nix-support/lisp-inputs"
        if [ -e "$lisp" ]; then
            local new_system
            for new_system in $(cat $lisp); do
                _addToExternalPath "$new_system"
            done
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
