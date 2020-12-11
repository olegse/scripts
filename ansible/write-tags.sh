#!/bin/bash
#
# Iterate blocks
#
# YAML_FILE   $1
# What happens when tags already exist?
# Add getopt at least

source ed.sh      # file manipulation library

# Processed files
declare -A files

# Tag name to append
# ! should be prompted for 
TAG="$2"

# Print usage if not enough parameters supplied
test "$#" -eq 2 || usage 

# Print usage and exit
function usage() {
  echo "Usage: `basename $0` FILE TAG"
  echo "Write tags under each task found in a file"
  exit
}

get_top_level_key_indent $1      # TOP_LEVEL_KEY_INDENT
get_task_lines $1
#files[$1]=${task_lines[0]}

# Print blocks
i=0

#while [ ${files[@]} ]
#do
#  while [ -n "${task_lines[$i]}" ]
#  do
#    block_start=${task_lines[$i]} 
#    block_end=${task_lines[((++i))]:-$} 
#
#    #DEBUG
#    print_block ${block_start} ${block_end}
#  done
#    if [ include_file=$(block_include) ] 
#    then
#      get_task_lines ${files[$include_file]:-1}
#      files[$include_file]=${task_lines[0]} 
#    else 
#      write_a_tag
#    fi
#    
#  # Line number should be incremented because each write
#  # adds a line
#  (( line += writes++ ))
#  if [ $DEBUG ]
#  then
#    echo -n "Processing line: $line "
#    sed -n "$line p" $yaml_file
#  fi
#  if [ 
#  if [ "$line" != "$" ]
#  then 
#    line=$(find_upper_block_end)
#  fi
#  #echo "writing under $line"
#  #echo "real_indent: |$real_indent|"
#  write_tag "$TAG"
#done
