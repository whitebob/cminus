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
trap 'echo "Signal received."; return -1' INT KILL
type c- &> /dev/null || PROMPT_COMMAND="${PROMPT_COMMAND:-:}"$';c-_pushd'
CMINUSHASH="' '"
CMINUSIGNORE="/\.git$|/\.git/|/node_modules$|/node_modules/"
CMINUSDISABLED=""
CMINUSMD5PROG="$( ( [ ! -z `command -v md5` ] && echo -n 'md5 -q -s' ) || ( [ ! -z `command -v md5sum` ] && echo -n '> >(md5sum) echo -n' ) || echo -n 'CMINUSDISABLED="True" && echo "No md5 found, Disable cminus"' )"
c-_pushd() {
        if [ ! -z ${CMINUSDISABLED} ]; then return 0; fi
        local pushpwd hashhead
        pushpwd=${OLDPWD}
        hashhead="$( eval ${CMINUSMD5PROG} \"`pwd`\" | cut -c-7 )" 
        [ -z $( pwd | egrep ${CMINUSIGNORE} ) ] && eval " case ${hashhead} in ${CMINUSHASH} ) ;; * ) CMINUSHASH+='|'${hashhead}; pushd . > /dev/null ;; esac ";
        OLDPWD=${pushpwd} # recover OLDPWD to make "cd -" work as before. 
}
c-_completion() {
        COMPREPLY=()
        if [ ! -z ${CMINUSDISABLED} ]; then return 0; fi
        local cur pre path match
        cur="${COMP_WORDS[COMP_CWORD]}"
        pre="${COMP_WORDS[COMP_CWORD-1]}"
        case ${pre} in
                "-s"|"-l"|"--save"|"--load" ) COMPREPLY=( $( compgen -f -- ${cur} ) );; # use file complete for save/load
                "-r"|"--refresh" ) ;; # refresh to remove duplicate items due to load or manual pushd operations
                "-f"|"--fuzzy" ) eval COMPREPLY=( $( compgen -W "$( for path in "${DIRSTACK[@]}"; do echo ${path}; done | tail -n +2 | sort | uniq | if [ -z ${cur} ]; then cat; else grep -e "${cur}";fi | sed -e "s:^:':g" -e s":$:':g" | while read match; do echo -n "$match "; done )" -- | sed -e "s:^:':g" -e "s:$:':g" ) );; # fuzzy match complete
               * ) eval COMPREPLY=( $( compgen -W "$( for path in "${DIRSTACK[@]}"; do echo \'${path}\'; done | tail -n +2 | sort | uniq )" --  ${cur} | sed -e "s:^:':g" -e "s:$:':g" ) );; # traditional complete style
        esac
        if (( ${#COMPREPLY[@]} > 1 )); then # show the candidates
                echo; for match in  "${COMPREPLY[@]}"; do echo ${match}; done | if [ -z ${cur} ]; then cat; else grep --color=always -e "${cur}"; fi | sort | uniq | column -c ${COLUMNS}; echo -e "\033[01;32m${#COMPREPLY[@]}\033[00m records matched." && echo -n ${COMP_WORDS[@]}
        fi
        return 0;
}
c-() {
        if [ ! -z ${CMINUSDISABLED} ]; then return 0; fi
        local path unistack
        case $1 in 
                "-f"|"--fuzzy" ) shift;;
                "-h"|"--help" ) shift;;
                "-s"|"--save" ) for path in "${DIRSTACK[@]}"; do echo ${path}; done | tail -n +2 > $2; return $?;;
                "-l"|"--load" ) while read path; do [ -z $( echo ${path} | egrep ${CMINUSIGNORE} ) ] && pushd -n "${path}"; done < $2 >/dev/null; CMINUSHASH="' '$( for path in "${DIRSTACK[@]}"; do echo "${path}"; done | tail -n +2 | while read path; do eval ${CMINUSMD5PROG} \"${path}\"; done | cut -c-7 | sed -e 's:^:|:g' | sort | uniq | xargs -n1 echo -n )"; return $?;;
                "-r"|"--refresh" ) unistack=(); eval unistack=( $( for path in "${DIRSTACK[@]}"; do echo \'${path}\'; done | tail -n +2 | sort | uniq ) ); dirs -c; for path in "${unistack[@]}"; do pushd -n "${path}"; done > /dev/null; CMINUSHASH="' '$( for path in "${DIRSTACK[@]}"; do echo "${path}"; done | tail -n +2 |while read path; do eval ${CMINUSMD5PROG} \"${path}\"; done | cut -c-7 | sed -e 's:^:|:g' | sort | uniq | xargs -n1 echo -n )"; return $?;;
        esac
        if [ -z "$*" ]; then
                echo -e "Usage: \nc- -f|--fuzzy re_expr\t(fuzzy search)\nc- -s|--save filename\t(save paths)\nc- -l|--load filename\t(load paths)\nc- -r|--refresh\t\t(refresh paths)\nc- -h|--help\t\t(this info)\nExample 1:\033[01;32m c- -f m.*n$ \033[00m to find path with re_format \"m.*n$\".\nExample 2:\033[01;32m c- -l <(find \`pwd\` -type d)\033[00m to load paths in current dir.\nExample 3:\033[01;32m c- -r \033[00m to clean duplicated dirs in stack.\nHit <Tab> after \"c- \"or \"c- -f \" to auto-complete the path.\nDon't forget the tailing <Space>."
        else
                cd "$*"; # quote is necessary when spaces in path
        fi
        return $?
}
complete -o bashdefault -F c-_completion c-
# vim: set et ts=8 sts=8 sw=8 :
