#   c- (cminus) is a bash script help you quickly go back to dirs visited. 
#   Copyright (C) 2018 Qi Liu <gwhitebob@gmail.com> 
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <https://www.gnu.org/licenses/>.

type c- &> /dev/null || PROMPT_COMMAND="$PROMPT_COMMAND"$';c-_pushd'
CMINUSHASH="' '"
CMINUSIGNORE=".git|node_modules"
c-_pushd() {
        local path pushpwd hashhead
        pushpwd=${OLDPWD}
        hashhead="$( md5 -q -s "`pwd`" | cut -c-7 )"
        [ -z $( pwd | egrep ${CMINUSIGNORE} )] && eval " case ${hashhead} in ${CMINUSHASH} ) ;; * ) CMINUSHASH+='|'${hashhead}; pushd . > /dev/null ;; esac ";
        OLDPWD=${pushpwd} # recover OLDPWD to make "cd -" work as before. 
}
c-_completion() {
        COMPREPLY=()
        local cur pre path match
        cur="${COMP_WORDS[COMP_CWORD]}"
        pre="${COMP_WORDS[COMP_CWORD-1]}"
        case ${pre} in
                "-f"|"--fuzzy" ) [ -z ${cur} ] || eval COMPREPLY=( $( compgen -W "$( for path in "${DIRSTACK[@]}"; do echo ${path}; done | tail -n +2 | sort | uniq | egrep ${cur} | sed -e "s:^:':g" -e s":$:':g" | while read match; do echo -n "$match "; done )" -- | sed -e "s:^:':g" -e "s:$:':g" ) ) && 
                        if (( ${#COMPREPLY[@]} >= 2 )); then # show the candidates
                                echo; for match in  "${COMPREPLY[@]}"; do echo ${match}; done |egrep --color=always ${cur} | column -c ${COLUMNS};echo -e "\033[01;32m${#COMPREPLY[@]}\033[00m records matched."; echo -n ${COMP_WORDS[@]};
                        fi 
                ;; # fuzzy match complete
                "-s"|"-l"|"--save"|"--load" ) COMPREPLY=( $( compgen -f -- ${cur} ) );; # use file complete for save/load
                "-r"|"--refresh" ) ;; # refresh to remove duplicate items due to load or manual pushd operations
        * ) eval COMPREPLY=( $( compgen -W "$( for path in "${DIRSTACK[@]}"; do echo \'${path}\'; done | tail -n +2 | sort | uniq )" --  ${cur} | sed -e "s:^:':g" -e "s:$:':g" ) ); (( ${#COMPREPLY[@]} > 1 )) && echo -e "\n\033[01;32m${#COMPREPLY[@]}\033[00m records matched." && echo -n ${COMP_WORDS[@]};; # traditional complete style
        esac
        return 0;
}
c-() {
        trap 'echo "Signal received."; return -1' INT KILL
        local path unistack
        case $1 in 
                "-f"|"--fuzzy" ) shift;; 
                "-s"|"--save" ) for path in "${DIRSTACK[@]}"; do echo ${path}; done | tail -n +2 > $2; return $?;; 
                "-l"|"--load" ) while read path; do [ -z $( echo ${path} | egrep ${CMINUSIGNORE} ) ] && pushd -n "${path}"; done < $2 >/dev/null; CMINUSHASH="' '$( dirs -l | tail -n +2 | cut -d\/ -f 2- | sed -e 's:^:"/:g'  -e 's:$:":g' | xargs -n1 md5 -q -s | cut -c-7 | sed -e 's:^:|:g' | sort | uniq | xargs -n1 echo -n )"; return $?;; 
                "-r"|"--refresh" ) unistack=(); eval unistack=( $( for path in "${DIRSTACK[@]}"; do echo \'${path}\'; done | tail -n +2 | sort | uniq ) ); dirs -c; for path in "${unistack[@]}"; do pushd -n "${path}"; done > /dev/null; CMINUSHASH="' '$( dirs -l | tail -n +2 | cut -d\/ -f 2- | sed -e 's:^:"/:g'  -e 's:$:":g' | xargs -n1 md5 -q -s | cut -c-7 | sed -e 's:^:|:g' | sort | uniq | xargs -n1 echo -n )"; return $?;; 
        esac
        cd "$*" # quote is necessary when spaces in path
        return $?
}
complete -o bashdefault -F c-_completion c-
# vim: set et ts=8 sts=8 sw=8 :
