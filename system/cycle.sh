#!/bin/bash
#
function find_diffs() {
  echo "in $FUNCNAME"
  declare -g -a dupped    # should be passed here somehow
  declare -n a_1=$1
  declare -n a_2=$2
  for f in ${a_2[@]}
  do
    echo "processing '$f'..."
    if_dupped a_1 $f
    #echo "Exist status from if_dupped: '$?'"
    if [[ $? -eq 0 ]]
    then
      dupped+=( $f )
    fi
  done
}

declare -a ttfs

IFS=$'\n'
declare -a origin=( $( find ~/.fonts/ -name "*ttf" -exec basename {} \; ) )
for file in $(find $1 -name "*.zip")
do
  # unzip file, parse for tf$ << accept it
  ttfs+=( $( unzip -l $file  | awk '/tf$/ {print $NF}' ) )
done

array_dump origin
array_dump ttfs
find_diffs origin ttfs
array_dump dupped
