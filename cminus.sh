PROMPT_COMMAND="$PROMPT_COMMAND"$';c-_pushd'

c-_pushd() { 
        eval "case $( md5 -q -s "`pwd`") in ' ' $( dirs -l | tail -n +2 | cut -d\  -f 4- |sed -e 's:^:":g'  -e 's:$:":g' | xargs -n1 md5 -q -s | sed -e 's:^: | :g' | xargs ) ) ;; * ) pushd . > /dev/null;; esac"; 
}

c-_completion() {
        COMPREPLY=()
        local cur pre
        cur="${COMP_WORDS[COMP_CWORD]}"
        pre="${COMP_WORDS[COMP_CWORD-1]}"
        case ${pre} in
                "-f"|"--fuzzy" ) COMPREPLY=( $( compgen -W "$( echo ${DIRSTACK[@]} | xargs -n1| tail -n +2 |grep ${cur}| xargs)" -- ) );; #fuzzy
                * ) COMPREPLY=( $( compgen -W "$( echo ${DIRSTACK[@]} | xargs -n1| tail -n +2 | xargs)" --  ${cur} ) );; #traditional
        esac
        return 0;
}

c-() {
        case $1 in "-f" ) shift;; esac
        cd $*;
        return $?;
}

complete -o bashdefault -F c-_completion c-
