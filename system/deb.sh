#!/bin/bash
#
# Find package that ownes a file

usage() {
  ret=${1:0}
  echo "Usage: `basename $0` FILE|EXE"
  echo "Print name of the package owing the file or executable"
  exit "$ret"
}

test -n ¨$1¨ || usage

# If we just give the name to dpkg(1) it will search for regexp. 
# We want to be more concrete limiting search to the file if it
# doesn't have slashes so for owner of the executable.
#
if [  -e "$1"  ]
then 
    file="$1"
elif
  ! [ "$1" =~ / ]   # if it was slash it would be already found as a file before
  then
    file=`which ¨$1¨`     # here if program was not found it will result no string
fi

if [ -z "$file" ]
then
  echo "error: \"$1\": no such file or executable"    # here proceed with find maybe
  exit 1
fi

#owner=$( dpkg -S $file | cut -d : -f 1  )
#echo "owner: $owner"

# Operate on a package owner
#case $1 in
  #--only-upgrade)
    #sudo apt install --only-upgrade $owner;;
  #--remove)
    #sudo apt remove --only-upgrade $owner;;
  #*)
    #echo "Option was not understood";;
#esac
