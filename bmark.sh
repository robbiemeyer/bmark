# Should not be run in a subshell

BMARKDELIM='~'

function bmark {
  local bmarkusage='Usage:
  bmark    {BMARK}       go to {BMARK}
  bmark -a {BMARK}       add bookmark named {BMARK} to current directory
  bmark -a {BMARK} {DIR} add bookmark named {BMARK} to {DIR}
  bmark -r {BMARK}       remove bookmark named {BMARK}
  bmark -l               list all bookmarks
  bmark -h               show usage information'


  if [ -z "$BMARKFILE" ]
  then
    echo '$BMARKFILE is unset' 1>&2
    return 1
  fi

  local o bmarkflags OPTIND
  while getopts ":a:r:lh" o
  do
    case "$o" in
      r) bmarkflags=${bmarkflags}remove ;;
      a) bmarkflags=${bmarkflags}add ;;
      l) bmarkflags=${bmarkflags}list ;;
      h) bmarkflags=${bmarkflags}showhelp ;;
      *) bmarkflags=${bmarkflags}invalid ;;
    esac
    shift
  done

  if [ -z "$bmarkflags" -a $# -eq 1 ]
  then
    local dir=$(grep -x "${1}${BMARKDELIM}.*" $BMARKFILE 2> /dev/null | cut -d "$BMARKDELIM" -f2- 2> /dev/null)
    if [ -z "$dir" ]
    then
      echo "Bookmark does not exist"
    else
      cd $dir
    fi

  elif [ "$bmarkflags" = "showhelp" ]
  then
    echo -e "$bmarkusage"

  elif [ "$bmarkflags" = "add" -a $# -le 2 ]
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

  elif [ "$bmarkflags" = "remove" -a $# -eq 1 ]
  then

    if $(cut -d "$BMARKDELIM" -f1 $BMARKFILE 2> /dev/null | grep -qx ${1})
    then
      sed "/${1}${BMARKDELIM}.*/d" $BMARKFILE > /tmp/bmarktemp
      mv /tmp/bmarktemp $BMARKFILE
    else
      echo "Bookmark does not exist" 1>&2
      return 1
    fi

  elif [ "$bmarkflags" = "list" -a $# -eq 0 ]
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

    echo "bmark: Invalid command" 1>&2
    echo -e "$bmarkusage" 1>&2
    return 1

  fi
}

function _bmark_compl() {
  echo $(cut -d "$BMARKDELIM" -f1 $BMARKFILE 2> /dev/null | grep "^${1}" 2> /dev/null)
}

function _bmark_compl_bash() {
  target=$([ "${COMP_WORDS[1]}" = '-r' ] && echo 2 || echo 1)
  if [ $COMP_CWORD -eq $target ]
  then
    COMPREPLY=( $(_bmark_compl ${COMP_WORDS[COMP_CWORD]}) )
  fi
}

function _bmark_compl_zsh() {
  target=$([ "${words[2]}" = '-r' ] && echo 3 || echo 2)
  if [ $CURRENT -eq $target ]
  then
    compadd -U $(_bmark_compl $PREFIX)
  fi
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
