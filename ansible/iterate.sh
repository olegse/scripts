#!/bin/bash
#
# Iterate blocks within yaml file

source yaml.sh      # file manipulation library
get_task_lines $1

while [ -n "${TASK_LINES[$task]}" ]
do
    BLOCK_START=${TASK_LINES[((task++))]}
    NEXT_BLOCK_START=${TASK_LINES[((task++))]:-$}
    echo "BLOCK_START: $BLOCK_START"
    echo "NEXT_BLOCK_START: $NEXT_BLOCK_START"
    BLOCK_END=$( find_upper_block_end $NEXT_BLOCK_START )
    echo "BLOCK_END: $BLOCK_END"
    debug_block $YAML_FILE $BLOCK_START $BLOCK_END

    echo "Write a tag for this block? (yes/no)"
    read answer
    if [ $answer == "yes" ]
    then
      echo "writing a tag..."
    fi
done
#  done
#    if [ include_file=$(block_include) ] 
#    then
#      get_TASK_LINES ${files[$include_file]:-1}
#      files[$include_file]=${TASK_LINES[0]} 
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
