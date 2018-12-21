type c- &> /dev/null || PROMPT_COMMAND="$PROMPT_COMMAND"$';c-_pushd'

c-_pushd() { 
        eval "
                case $( md5 -q -s "`pwd`") in 
                        ' ' $( dirs -l | tail -n +2 | cut -d\  -f 4- | sed -e 's:^:":g'  -e 's:$:":g' | xargs -n1 md5 -q -s | sed -e 's:^: | :g' | xargs ) ) ;; 
                        * ) pushd . > /dev/null;; 
                esac
        "; 
}

c-_completion() {
        COMPREPLY=()
        local cur pre
        cur="${COMP_WORDS[COMP_CWORD]}"
        pre="${COMP_WORDS[COMP_CWORD-1]}"
        case ${pre} in
                "-s"|"-l"|"--save"|"--load" ) COMPREPLY=( $( compgen -f -- ${cur} ));; # use file complete for save/load
                "-f"|"--fuzzy" ) [ -z ${cur} ] || COMPREPLY=( $( compgen -W "$( echo ${DIRSTACK[@]} | xargs -n1 | tail -n +2 | grep ${cur}| xargs)" -- ) ) && 
                        if (( ${#COMPREPLY[@]} >= 2 )); then # show the candidates
                                echo
                                echo ${COMPREPLY[@]} | xargs -n1 | column -c ${COLUMNS}
                                echo -n ${COMP_WORDS[@]}
                        fi 
                ;; # fuzzy match complete
                * ) COMPREPLY=( $( compgen -W "$( echo ${DIRSTACK[@]} | xargs -n1| tail -n +2 | xargs)" --  ${cur} ) );; # traditional complete style
        esac
        return 0;
}

c-() {
        local path
        case $1 in 
                "-f"|"--fuzzy" ) shift;; 
                "-s"|"--save" ) echo ${DIRSTACK[@]} | xargs -n1 | tail -n +2 > $2; return $?;; 
                "-l"|"--load" ) while read path; do pushd -n ${path}; done < $2; return $?;; 
        esac
        cd $*
        return $?
}

complete -o bashdefault -F c-_completion c-
# vim: set et ts=8 sts=8 sw=8 :
