#!/bin/bash
# ver: 0.1.0

CMDS="json install package term suggest init update list show getdeps"
CMDS_term="write cursor color background move transition clear reset bright dim underline blink reverse hidden"
CMDS_show="-V -h readme source"
flags="-h -V"
flags_json="-b -l -p -h"
flags_list="-h --help -V --Version -d --details"
flags_getdeps="-h --help"

function _bpkg-completion
{
  local cur prev cword  
  _get_comp_words_by_ref -n : cur prev cword

  packages=($(bpkg list))

  # if there's no words before, return all subcommands
  if [ ${#COMP_WORDS[@]} -le 2 ]
  then
    COMPREPLY=($(compgen -W "$flags $CMDS" -- "$cur"))
  else

    case "${COMP_WORDS[1]}" in
      "json" ) COMPREPLY=($(compgen -W "$flags_json" -- "$cur"));;
      "install" ) COMPREPLY=($(compgen -W "${packages[*]}" -- "$cur"));;
      "term" ) COMPREPLY=($(compgen -W "$CMDS_term" -- "$cur"));;
      "suggest" ) COMPREPLY=($(compgen -W "$flags" -- "$cur"));;
      "init" ) COMPREPLY=($(compgen -W "$flags" -- "$cur"));;
      "update" ) COMPREPLY=($(compgen -W "$flags" -- "$cur"));;
      "list" ) COMPREPLY=($(compgen -W "$flags_list" -- "$cur"));;
      "getdeps" ) COMPREPLY=($(compgen -W "$flags_getdeps" -- "$cur"));;
      "package" )
        # return all parameters in package.json
        if [ -f ./package.json ]
        then
          temp=$(mktemp "/tmp/bpkg-comp.tmp.XXXXX")
          echo $(cat ./package.json | bpkg json -b) > $temp
          vim -e -s "$temp" <<-EOT
          %s/ /\r/g
          g/^[^\[]/d
          %s/,.*$//g
          %s/[\[\]"]//g
          %s/r/,/g
          %s/[\n\r]/ /g
          %s/,/r/g
          w!
EOT
          rep=$(cat $temp)
          rm "$temp"
          COMPREPLY=($(compgen -W "$rep" -- "$cur"))
        fi
        ;;
      "show" )
        case "${COMP_WORDS[2]}" in
          "readme" ) COMPREPLY=($(compgen -W "${packages[*]}" -- "$cur"));;
          "source" ) COMPREPLY=($(compgen -W "${packages[*]}" -- "$cur"));;
          "-V" | "-h" ) ;;
          * ) COMPREPLY=($(compgen -W "$CMDS_show ${packages[*]}" -- "$cur"));;
        esac
        ;;
     * ) echo nothing was detected;;
    esac
  fi


}

complete -F _bpkg-completion bpkg
