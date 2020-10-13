#!/bin/bash
# 
# Just an example, not the best solution.

# Grep through all the included files
declare -a files=$( nginx -T 2>&1 | sed -n 's,# configuration file \(\(\/[a-zA-Z_.]\+\)\+\).*,\1,p' )

function dump() {
  declare -n a=$1
  echo "${a[@]}"
  echo "${#a[@]}"
  for((i=0; $i < ${#a[@]}; i++))
  do
    echo "$i: '${a[$i]}'"
  done
}

declare -A blocks
declare -a open_brackets
declare -a brackets=( $(awk '/{|}/ {print NR}' $ngx_file ) )
j=0     # index of the next bracket pair start in open_brackets

for((i=0; $i < ${#brackets[@]}; i++))
do
  if sed -n "${brackets[$i]} p" $ngx_file | grep '{'
  then
    echo "Opening bracket found!"
    # Store the index
    open_brackets[$j]=${brackets[$i]};
    (( j++ ))
    echo "j: $j"
    for((m=0; $m < $j; m++))
    do
      echo "open_brackets[$m]: ${open_brackets[$m]}"
    done
      echo ">>>"
  else
    echo "Closing bracket found!"
    blocks[${open_brackets[((--j))]}]=${brackets[$i]}
    echo "j: $j"
    echo "open_brackets[$j]: ${open_brackets[$j]}"
    echo "${open_brackets[$j]} <-> ${blocks[${open_brackets[$j]}]}  "
  fi
done

echo "PARSE_END"
for start in ${!blocks[@]}
do
  echo "$start <-> ${blocks[$start]}"
done

# Find 'server' blocks
declare -a servers=$( awk -F: '/^ *server *}? *$/ {print NR}' $ngx_file )
for server in ${servers[@]}
do
  # find closest bracket
  # then determine the range and parse it!
# Now.. where is server directive starts and where specific 'listen' directive belongs?
num=2
for start in ${!blocks[@]}
do
  block_start=$start; block_end=${blocks[$start]}
  if [ $num -gt $block_start -a $num -lt $block_end ]
  then
    echo "$num range found!"
    echo "$block_start <-> $block_end"
    break
  fi
done

# Next is to find closest bracket to the server directive, so what were the options
# to find a line number:
#
# 1. awk '/<pattern>/ {print NR}' FILE
