#!/bin/bash
#
# Find package that ownes a file

usage() {
  ret=${1:-0}
  echo "Usage: `basename $0` FILE|EXE"
  echo "Print name of the package owing the file or executable"
  exit "$ret"
}
test -n "$1" || usage

# If we just give the name to dpkg(1) it will search for regexp. 
# We want to be more concrete limiting search to the file if it
# doesn't have slashes so for owner of the executable.
if [  -e "$1"  ]
then 
    file="$1"
    # here if it is in the current directory == has no slashes, './' should
    # be appended, otherwise will be treated as the pattern
elif
  ! [[ "$1" =~ / ]]   # if it was slash it would be already found as a file before
  then
    file=`which $1`     # here if program was not found it will result in no string
fi

# Now $file is set to be an absolute path, otherwise it will be treated by `dpkg -S' as 
# a regexp and result in displaying all the files that match the pattern in the matched 
# package names.

if [ -z "$file" ]
then
  echo "error: \"$1\": no such file or executable"    
  exit 1
  # here proceed with find maybe
fi

owner=$( dpkg -S $file | cut -d : -f 1  )
echo "owner: $owner"

# -l   how I was parsing the options? waht were the methods?

# Operate on a package owner
#case $1 in
  #--only-upgrade)
    #sudo apt install --only-upgrade $owner;;
  #--remove)
    #sudo apt remove --only-upgrade $owner;;
  #*)
    #echo "Option was not understood";;
#esac
