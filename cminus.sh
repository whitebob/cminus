type c- &> /dev/null || PROMPT_COMMAND="$PROMPT_COMMAND"$';c-_pushd'

c-_pushd() {
        local path pushpwd
        pushpwd=${OLDPWD}
        eval "  
                case $( md5 -q -s "`pwd`") in 
                        ' ' $( dirs -l | tail -n +2 | cut -d\/ -f 2- | sed -e 's:^:"/:g'  -e 's:$:":g' | xargs -n1 md5 -q -s | sed -e 's:^: | :g' | xargs ) ) ;; 
                        * ) pushd . > /dev/null;; 
                esac
        ";
        OLDPWD=${pushpwd} # recover OLDPWD to make "cd -" work as before. 
}

c-_completion() {
        COMPREPLY=()
        local cur pre path match
        cur="${COMP_WORDS[COMP_CWORD]}"
        pre="${COMP_WORDS[COMP_CWORD-1]}"
        case ${pre} in
                "-s"|"-l"|"--save"|"--load" ) COMPREPLY=( $( compgen -f -- ${cur} ));; # use file complete for save/load
                "-f"|"--fuzzy" ) [ -z ${cur} ] || eval COMPREPLY=( $( compgen -W "$( for path in "${DIRSTACK[@]}"; do echo \'${path}\'; done | tail -n +2 |sort | uniq | egrep ${cur} | while read match; do echo -n "$match "; done )" -- | sed -e "s:^:':g" -e "s:$:':g" ) ) && 
                        if (( ${#COMPREPLY[@]} >= 2 )); then # show the candidates
                                echo
                                for match in  "${COMPREPLY[@]}"; do echo ${match}; done | column -c ${COLUMNS}
                                echo -n ${COMP_WORDS[@]}
                        fi 
                ;; # fuzzy match complete
                * ) eval COMPREPLY=( $( compgen -W "$( for path in "${DIRSTACK[@]}"; do echo \'${path}\'; done | tail -n +2 |sort | uniq )" --  ${cur} | sed -e "s:^:':g" -e "s:$:':g" ) );; # traditional complete style
        esac
        return 0;
}

c-() {
        local path
        case $1 in 
                "-f"|"--fuzzy" ) shift;; 
                "-s"|"--save" ) for path in "${DIRSTACK[@]}"; do echo ${path}; done | tail -n +2 > $2; return $?;; 
                "-l"|"--load" ) while read path; do pushd -n "${path}"; done < $2 >/dev/null; return $?;; 
        esac
        cd "$*" # quote is necessary when spaces in path
        return $?
}

complete -o bashdefault -F c-_completion c-
# vim: set et ts=8 sts=8 sw=8 :
