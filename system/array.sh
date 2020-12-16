#!/bin/bash
# Now, find intersection
source ~/scripts2/lib/functions.sh
print_2() {
  declare -n arr_2=$1
  echo "\$1: $1"
  for e in ${arr_2[@]}
  do
    echo "$((i++)): $e"
  done
}
print_1() {
  declare -n arr_1=$1
  echo "\$1: $1"
  for e in ${arr_1[@]}
  do
    echo "$((i++)): $e"
    if_dupped arr_1 $e && echo "returned true"
  done
}

declare -a a_1=( {a..c..2} )
print_1  a_1
