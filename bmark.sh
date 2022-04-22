# Should not be run in a subshell

BMARKDELIM='~'

function bmark {
  local bmarkusage='Usage: bmark  {BMARK} go to {BMARK}
      -a {BMARK} add bookmark named {BMARK} to current directory
      -a {BMARK} {DIR} add bookmark named {BMARK} to {DIR}
      -r {BMARK} remove bookmark named {BMARK}
      -l         list all bookmarks'


  if [ -z "$BMARKFILE" ]
  then
    echo '$BMARKFILE is unset' 1>&2
    return 1
  fi

  if [ $# -eq 0 ]
  then
    echo -e "$bmarkusage"
  
  else
    local o bmarkflags OPTIND

    while getopts ":a:r:lh" o
    do
      case "$o" in
        r) bmarkflags=${bmarkflags}remove ;;
        a) bmarkflags=${bmarkflags}add ;;
        l) bmarkflags=${bmarkflags}list ;;
        *) bmarkflags=${bmarkflags}invalid ;;
      esac
      shift
    done

    if [ -z "$bmarkflags" ]
    then

      local dir=$(grep -x "${1}${BMARKDELIM}.*" $BMARKFILE 2> /dev/null | cut -d "$BMARKDELIM" -f2- 2> /dev/null)
      if [ -z "$dir" ]
      then
        echo "Bookmark does not exist"
      else
        cd $dir
      fi

    elif [ "$bmarkflags" = "add" ]
    then
      
      if $(cut -d "$BMARKDELIM" -f1 $BMARKFILE 2> /dev/null | grep -qx ${1})
      then
        echo "Bookmark already exists" 1>&2
        return 1
      elif [ -z "${1##*$BMARKDELIM*}" ]
      then
        echo "The bmark name can not contain '$BMARKDELIM' as it is the current bmark delimiter" 1>&2
        return 1
      elif [ $2 ]
      then
        echo "${1}${BMARKDELIM}${2}" >> $BMARKFILE
      else
        echo "${1}${BMARKDELIM}${PWD}" >> $BMARKFILE
      fi

    elif [ "$bmarkflags" = "remove" ]
    then
      
      if $(cut -d "$BMARKDELIM" -f1 $BMARKFILE 2> /dev/null | grep -qx ${1})
      then
        sed "/${1}${BMARKDELIM}.*/d" $BMARKFILE > /tmp/bmarktemp
        mv /tmp/bmarktemp $BMARKFILE
      else
        echo "Bookmark does not exist" 1>&2
        return 1
      fi

    elif [ "$bmarkflags" = "list" ]
    then

      if [ -s $BMARKFILE ]
      then

        local maxlen=$(echo Bookmark | cat - $BMARKFILE | cut -d "$BMARKDELIM" -f1 | wc -L)
        local maxlen=$((maxlen + 2))
        local fmt="%-${maxlen}s%s\n"

        printf $fmt Bookmark Path
        printf $fmt "========" "===="
        while IFS="$BMARKDELIM" read -r name dir
        do
          printf $fmt "$name" "$dir"
        done < $BMARKFILE

      else
        echo "No bookmarks found" 1>&2
        return 1
      fi

    else

      echo "Invalid command" 1>&2
      echo $bmarkusage 1>&2
      return 1

    fi
  fi
}

function _bmark_compl() {
  echo $(cut -d "$BMARKDELIM" -f1 $BMARKFILE 2> /dev/null | grep "^${1}" 2> /dev/null)
}

function _bmark_compl_bash() {
  COMPREPLY=( $(_bmark_compl ${COMP_WORDS[COMP_CWORD]}) )
}

function _bmark_compl_zsh() {
  compadd $(_bmark_compl $PREFIX)
}

if type complete &>/dev/null
then
    # bash
    complete -F _bmark_compl_bash bmark
    complete -F _bmark_compl_bash bmark -r
elif type compdef &>/dev/null
then
    # zsh
    compdef _bmark_compl_zsh bmark
    compdef _bmark_compl_zsh bmark -r
fi
