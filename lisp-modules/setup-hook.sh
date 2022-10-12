copyFilesPreservingDirs () {
    local to="$1"
    for file in $systemFiles $extraFiles; do
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

outputLispConfigs () {
    local extra="$1"
    declare -A lispPathsSeen=()
    for system in $extra $lispInputs; do
        _outputLispConfigs $system
    done
    addToSearchPath "XDG_CONFIG_DIRS" "$out/share"
}

_outputLispConfigs ()  {
    local system="$1"
    local sr="share/common-lisp/source-registry.conf.d"
    local aot="share/common-lisp/asdf-output-translations.conf.d"
    if [ -v lispPathsSeen[$system] ]; then
        return
    else
        lispPathsSeen[$system]=1
        if [ -d "$system" ]; then
            local srfile="$out/$sr/$(stripHash $system).conf"
            local aotfile="$out/$aot/$(stripHash $system).conf"
            [ ! -f "$srfile" ] && echo "(:tree \"$system\")" > "$srfile"
            [ ! -f "$aotfile" ] && echo "(\"$system\" t)" > "$aotfile"
            if [ ! "$system" = "$out" ]; then
                if [[ -d "$system/$sr" && -d "$system/$aot" ]]; then
                    find "$system/$sr" -name "*" -type f,l -exec \
                         ln -sf {} "$out/$sr/" \;
                    find "$system/$aot" -name "*" -type f,l -exec \
                         ln -sf {} "$out/$aot/" \;
                fi
            fi
        fi
    fi
}

buildPathsForLisp () {
    declare -A lispPathsSeen=()
    declare -A extPathsSeen=()

    for package in $lispInputs $buildInputs $propagatedBuildInputs; do
        _addToExternalPath $package
    done
    export HOME="$out"
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
        local prop="$package/nix-support/propagated-build-inputs"
        if [ -e "$prop" ]; then
            local new_package
            for new_package in $(cat $prop); do
                _addToExternalPath "$new_package"
            done
        fi
    fi
}

addEnvHooks "$targetOffset" buildPathsForLisp
