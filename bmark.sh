# Should not be run in a subshell

function bmark {
  local bmarkusage='Usage: bmark  {BMARK} go to {BMARK}
      -a {BMARK} add bookmark named {BMARK} to current directory
      -a {BMARK} {DIR} add bookmark named {BMARK} to {DIR}
      -r {BMARK} remove bookmark named {BMARK}
      -l         list all bookmarks'

  local delim='~'

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

      local dir=$(grep -x "${1}${delim}.*" $BMARKFILE 2> /dev/null | cut -d "$delim" -f2- 2> /dev/null)
      if [ -z "$dir" ]
      then
        echo "Bookmark does not exist"
      else
        echo $dir
      fi

    elif [ "$bmarkflags" = "add" ]
    then
      
      if $(cut -d "$delim" -f1 $BMARKFILE 2> /dev/null | grep -qx ${1})
      then
        echo "Bookmark already exists" 1>&2
        return 1
      elif [ -z "${1##*$delim*}" ]
      then
        echo "The bmark name can not contain '$delim' as it is the current bmark delimiter" 1>&2
        return 1
      elif [ $2 ]
      then
        echo "${1}${delim}${2}" >> $BMARKFILE
      else
        echo "${1}${delim}${PWD}" >> $BMARKFILE
      fi

    elif [ "$bmarkflags" = "remove" ]
    then
      
      if $(cut -d "$delim" -f1 $BMARKFILE 2> /dev/null | grep -qx ${1})
      then
        sed "/${1}${delim}.*/d" $BMARKFILE > /tmp/bmarktemp
        mv /tmp/bmarktemp $BMARKFILE
      else
        echo "Bookmark does not exist" 1>&2
        return 1
      fi

    elif [ "$bmarkflags" = "list" ]
    then

      if [ -s $BMARKFILE ]
      then

        local maxlen=$(echo Bookmark | cat - $BMARKFILE | cut -d "$delim" -f1 | wc -L)
        local maxlen=$((maxlen + 2))
        local fmt="%-${maxlen}s%s\n"

        printf $fmt Bookmark Path
        printf $fmt "========" "===="
        while IFS="$delim" read -r name dir
        do
          printf $fmt $name $dir
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

