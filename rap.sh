#  Wrapper script from which to organize and call scripts.
#
#
get_line_from_file() { local lineNum=$1; local file=$2
  head -$lineNum $file | tail -n -1 | sed 's/\\n/\n/g' | tail -c +4
}

make_auto_complete_file() { local file=$1
  rm -rf "$file"
  echo "_complete()" >> "$file" 
  echo "{" >> "$file" 
  echo "  local cur=\${COMP_WORDS[COMP_CWORD]}" >> "$file"
  echo "  COMPREPLY=( \$(compgen -W \"${COMPLETIONS}\" -- \$cur) )" >> "$file"
  echo "}" >> "$file"
  echo "complete -f -F _complete ${THIS}" >> "$file"
}

add_to_bash_if_not_there() { local file=$1
  srcline="source $file"
  if ! $(grep -q "${srcline}" "$HOME/.bashrc") ; then
    echo "${srcline}" >> "$HOME/.bashrc"
    mkdir -p "$HOME/bin"
    echo "export PATH=\$PATH:$HOME/bin" >> "$HOME/.bashrc"
    export PATH=$PATH:$HOME/bin
  fi
}

print_usage_header() {
  echo "Usage:"
  echo "  ${THIS} <command> <arg1> <arg2> ..."
  echo "  ${THIS} help <command>"
  echo "  ${THIS} help all"
  echo "  ${THIS} cat <command>"
  echo "Available commands:"
}

setup_completions() { local dir=$1
  for f in $dir/* ; do
    if [ -f "$f" ]; then
      fname=`basename $f`
      cmdname=${fname%.*}
      COMPLETIONS="$COMPLETIONS $cmdname"
    elif [ -d "$f" ]; then
      setup_completions $f
    fi
  done
}

setup_all_completions() {
  COMPLETIONS=help
  setup_completions $DEFLATED_DIR
  make_auto_complete_file "$HOME/.${THIS}-completion.sh"
  add_to_bash_if_not_there "$HOME/.${THIS}-completion.sh"
  source "$HOME/.${THIS}-completion.sh" 
}

print_usage() { local dir=$1
  for f in $dir/* ; do
    if [ -f "$f" ] && [[ $f != */_* ]]; then
      fname=`basename $f`
      cmdname=${fname%.*}
      extension="${fname##*.}"
      desc=`get_line_from_file 1 $f` 
      printf "  %-22s%-10s%s\n" "$cmdname" "($extension)" "${desc}"
    fi
  done
}

print_usage_subcommand() { local cmdfile=$1; local subcmd=$2
  extension="${cmdfile##*.}"
  desc=`get_line_from_file 1 $cmdfile`
  opts=`get_line_from_file 2 $cmdfile`
  exOpts=`get_line_from_file 3 $cmdfile`
  echo "Usage:"
  echo "  $THIS $subcmd $opts"
  echo "Example:"
  echo "  $THIS $subcmd $exOpts"
  echo "Description:"
  echo "  $desc"
  echo "Type:"
  echo "  ($extension)"  
}

command_not_found() { local command=$1
  echo "Command not found '${command}'. Are you sure it was included in the zip?"
}

THIS=`basename $0 .sh`
cmd=$1
subcmd=$2
HOME=`cd ~; pwd;`
DEFLATED_DIR="$HOME/.${THIS}-scripts"

unzip -uoqq "$HOME/${THIS}-scripts.zip" -d ${DEFLATED_DIR}

if [ "help" = "$cmd" ] && [ "" = "$subcmd" ]; then
  print_usage_header
  print_usage $DEFLATED_DIR
  setup_all_completions
  exit 0
fi

if [ "help" = "$cmd" ] && [ "all" = "$subcmd" ]; then
  print_usage_header
  print_usage $DEFLATED_DIR
  subDirs=`find $DEFLATED_DIR/* -type d | sort`
  for d in $subDirs ; do
    relativePath=${d//$DEFLATED_DIR/}
    if [[ $relativePath != */_* ]]; then
      echo "$relativePath/"
      print_usage $d
    fi
  done
  setup_all_completions
  exit 0
fi

if [ "help" = "$cmd" ] && [ "" != "$subcmd" ]; then
  cmdfile=(`find $DEFLATED_DIR -name "${subcmd}.*"`)
  if [ -z "${cmdfile}" ]; then
    command_not_found $subcmd
  else
    print_usage_subcommand $cmdfile $subcmd
  fi
  exit 0
fi

if [ "cat" = "$cmd" ] && [ "" != "$subcmd" ]; then
  cmdfile=(`find $DEFLATED_DIR -name "${subcmd}.*"`)
  if [ -z "${cmdfile}" ]; then
    command_not_found $subcmd
  else
    cat $cmdfile
    echo ""
  fi
  exit 0
fi

set -e
shift
cmdfile=(`find $DEFLATED_DIR -name "${cmd}.*"`)
if [ -z "${cmdfile}" ]; then
  command_not_found $cmd
  exit 1
else
  extension="${cmdfile##*.}"
  if [ "hive" == "$extension" ]; then
    hive -f $cmdfile "$@"
  elif [ "pig" == "$extension" ]; then
    pig "$@" $cmdfile
  else
    $extension $cmdfile "$@"
  fi
fi
exit 0