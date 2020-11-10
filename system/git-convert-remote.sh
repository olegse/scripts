#!/bin/bash
#
# Convert http url to ssh url and vice versa.
# In '.git/config'.
#
# url = https://github.com/olegse/scripts


usage() {
  echo "Usage: `basename $0` -t|-i"
  echo "Convert upstream url within '.git/config' file. I.e.:"
  echo "  url = https://github.com/olegse/scripts ->  url = git@github.com-olegse:olegse/scripts.git"
  echo "    -t    display the resulting line (do not edit)"
  echo "    -i    edit a file"
  exit 1
}

#pwd
if (( $# == 0 )); then usage; fi

while getopts ":ti" OPT
do
  echo "Processing: $OPT"
  case $OPT in
   't') action='-n' ;;
   'i') action='-i' ;;
   '?') echo "Invalid option '-$OPTARG'"
        usage ;;
  esac
done

# Append path to the file name (defaults to '.')
path=${!OPTIND:-.};
GIT_CONF=$path/.git/config

echo "action: $action"
sed ${action} '/url/ s|\w\+://\([-a-zA-Z~._]\+\)/\(\([-a-zA-Z~._]\+\)/[-a-zA-Z~._]\+\)|git@\1-\3:\2.git|' $GIT_CONF
