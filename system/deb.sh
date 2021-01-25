#!/bin/bash
#
# Find package that ownes a file

usage() {
  ret=${1:-0}
  echo "Usage: `basename $0` FILE|EXE"
  echo "Print name of the package owing the file or executable"
  echo "  -l, --list[=<type>]     list files in a package. Regular file by default."
  echo "                          Accepted values are same as type specifiers for find(1)."
  echo "  -t, --types             list distributed file types as reported by file(1) command"
  echo "                              *not implemented"
  exit "$ret"
}
test -n "$1" || usage

# Process options 
declare -a patterns
for option; do
  case ${option} in
    -l|--list)  ((list++));;
                # process filetypes
    -*)         echo "`basename $0`: invalid option --  '$option'"; exit;;
     *)         patterns+=${option};;
  esac
done
echo "list: $list"

for p in ${patterns[@]};
do
  echo "Processing pattern '$p'"
  

  # If we just give the name to dpkg(1) it will search for regexp. 
  # We want to be more concrete limiting search to the file if it
  # doesn't have slashes so for owner of the executable.
  if [  -e "$p"  ]
  then 
      file="$p"
      echo "Found a file matching '$file'"
       #here if it is in the current directory == has no slashes, './' should
       #be appended, otherwise will be treated as the pattern
  elif
    ! [[ "$p" =~ / ]]   # if it was slash it would be already found as a file before
   then
      echo "no such file, searching for executable matching '$p'"    
      file=`which $p`     # here if program was not found it will result in no string
  fi

  # Now $file is set to be an absolute path, otherwise it will be treated by dpkg -S as 
  # a regexp and result in displaying all the files that match the pattern in the matched 
  # package names.

  if [ -z "$file" ]
  then
    echo "no such executable, searching for package names matching the pattern '$p'"
    PS3="Choose the package: "
    select owner in $( apt list --installed "*$p*" ); do
        if [ -n "$REPLY" ]; then break; fi
    done
    if [ -n "$owner" ]
    then
      echo "Found package owner matching pattern '$p'"
    fi
  else
    echo "Found executable file for the '$p' pattern. Searching for file owner..."
    if [ -z "$owner" ]
    then
      owner=$( dpkg -S $file | cut -d : -f 1  )
    fi
  fi

  if [ -z "$owner" ]
  then
    echo "No matching filename, executable or package found for the given pattern" 1>&2
    exit 1
  fi
  echo "owner: $owner"

  # Perform an action
  if [ "$list" ]
  then
    for file in $( dpkg -L $owner )
    do
      test -f $file && file "$file"
    done
  fi
done
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
