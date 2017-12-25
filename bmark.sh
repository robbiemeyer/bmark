#Should not be run in a subshell

function bmark {
  local bmarkusage='Usage: bmark  {BMARK} go to {BMARK}
      -a {BMARK} add bookmark named {BMARK} to current directory
      -a {BMARK} {DIR} add bookmark named {BMARK} to {DIR}
      -r {BMARK} remove bookmark named {BMARK}
      -l         list all bookmarks'

  if [ -z "$BMARKFILE" ]
  then
    echo '$BMARKFILE is unset'
    return 1
  fi

  if [ $# -eq 0 ]
  then
    echo -e "$bmarkusage"
  
  else
    local o bmarkflags OPTIND

    while getopts "a:r:lh" o
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

      local dir=$(grep -x "${1}~.*" $BMARKFILE 2> /dev/null | cut -d '~' -f2- 2> /dev/null)
      if [ -z "$dir" ]
      then
        echo "Bookmark does not exist"
      else
        cd $dir
      fi

    elif [ "$bmarkflags" = "add" ]
    then
      
      if $(cut -d '~' -f1 $BMARKFILE 2> /dev/null | grep -qx ${1})
      then
        echo "Bookmark already exists"
      elif [ $2 ]
      then
        echo "${1}~${2}" >> $BMARKFILE
      else
        echo "${1}~${PWD}" >> $BMARKFILE
      fi

    elif [ "$bmarkflags" = "remove" ]
    then
      
      if $(cut -d '~' -f1 $BMARKFILE 2> /dev/null | grep -qx ${1})
      then
        sed "/${1}~.*/d" $BMARKFILE > /tmp/bmarktemp
        mv /tmp/bmarktemp $BMARKFILE
      else
        echo "Bookmark does not exist"
      fi

    elif [ "$bmarkflags" = "list" ]
    then

      if [ -s $BMARKFILE ]
      then
        echo -e 'Bookmark~Path\n========~====' | cat - $BMARKFILE | column -t -s '~' 
      else
        echo "No bookmarks found"
      fi

    else

      echo "Invalid command"
      echo $bmarkusage

    fi
  fi
}

