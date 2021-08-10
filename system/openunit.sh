#!/bin/bash
#
# Open a systemctl unit file(s) matching the pattern. The pattern
# is basic regular expression. If more than one file matched, display
# select prompt. 
#
# Need to accept on of the -o,-O and -p options affecting how vim opens
# multiple files.
if [ -z "$1" ]
then
  echo "Usage: `basename $0` UNIT..."
  exit 1
fi

# Convert do app -> do\|app

# Get all units matching pattern
units=( `systemctl list-unit-files | awk '/'"$1"'/ { print $1 }'` )

if [ ${#units[@]} -ne 1 ]   # If found more than 1 unit, display 
then                        # selection
  PS3="Select unit to open (or all): "
  select unit in ${units[@]}
  do 
    if [ -n "${unit}"  ]  # specific unit was selected
    then
      units=( $unit )   # limit vim call to the one element only
      break
    fi
    if [ $REPLY = all ] # display all units
    then
      break
    fi
  done
fi

echo "Opening a systemunit '${units[@]}'..."
echo "Getting system path..."
for unit in ${units[@]} # To open units need to get their real path
do
  # First find a path of the specific unit, write it on the same array index, and 
  # increment the index to be ready to process next element.
  units[((i++))]=`systemctl status $unit | sed -n '/Loaded/ s/.*(\([^;]\+\);.*$/\1/p'`
  echo "units: ${units[@]}"
done

# Edit unit files:
#   -p[N]     Open N tab pages or one
#   -o[N]     Open N windows (splits), or one
#   -O[N]     Like -o, but split vertically
vim -p ${units[@]}
