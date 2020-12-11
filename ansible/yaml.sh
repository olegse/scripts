# YAML FORMAT PARSING
#
# Variables:
# 
#  YAML_FILE                   yaml file that is parsed
#
# Functions:
#
#  find_upper_block_end        prints a line number of the upper (previous) block
#  write_tag                   append a tag to the block end


### Globals ###
declare -g task
task=0

### Libraries ###
. debug.sh

### Functions ###

# Print lines on which include statement is found.
# Ranges are specified by line numbers stored in keys[]
function find_include() {
  
  sed -n "$1,$2 {/include/p}" $yaml_file
}

# Print all included statements found in ranges
function find_includes() {

  # Iterate ${keys[@]}
  while [ ${keys[$i]} ]
  do
    find_include ${keys[((i++))]} ${keys[((i++))]:=$}
    if [ $DEBUG ]
    then
      debug_block
    fi
  done
}

# Find line number of the end of the previous block. Used to write the
# tag afterwards (or display blocks).
#
#   Usage: find_upper_block_end NEXT_BLOCK_START INITIAL_INDENT
#
#   Variables:
#     YAML_FILE          file to write to
#     INITIAL_INDENT     spaces till the top level key
#     NEXT_BLOCK_START    line number of the start of the next block
# 
function find_upper_block_end() {

  NEXT_BLOCK_START=${NEXT_BLOCK_START:-$1}    # using cat(1) here

  # Expression searches for non-empty lines
  cat -n $YAML_FILE | \
  sed -n "$BLOCK_START,$NEXT_BLOCK_START {/\d\+\s*\w/p}" | \
  awk 'END {print $1}'
  
  # Only last is printed
}

# Write a tag
#   $1   tag itself
#   $yaml_file    file to write to
#   $real_indent  spaces to take before writting
function write_tag() {
if [ $DEBUG ]
then
  echo "Appending after:"
  echo -e "line: $line"; sed -n "$line p" $yaml_file
fi

ed -s $yaml_file <<EOF 
$line a
${real_indent}tags: $1
.
w
q
EOF
}

# Store space identation of the top level key. Used to find all the other
# tasks.
#
#   Usage: get_top_level_key_indent $YAML_FILE
#
# Variables:
#   TOP_LEVEL_KEY_LINE       line number for the very first block
#   TOP_LEVEL_KEY_INDENT     spaces indent up to first character of the
#                            very first block
#   TOP_LEVEL_KEY_INDENT_FOUND 
#                            (flag) used to signal that indent was already found
function get_top_level_key_indent() {
  YAML_FILE=${YAML_FILE:-$1} 
  test "$YAML_FILE" || { echo "get_top_level_key_indent: missing file name to parse"; exit; }

  # Line number of the top level key
  TOP_LEVEL_KEY_LINE=$(grep -m1 -n -e "^ *- *[[:alnum:]]\+" ${YAML_FILE} | awk -F: '{print $1}')

  # Debug the line
  if [ $DEBUG]; then printl "$YAML_FILE" "$TOP_LEVEL_KEY_LINE"; fi

  # Spaces identation of the top key line
  TOP_LEVEL_KEY_INDENT=$(sed -n "$TOP_LEVEL_KEY_LINE s/^\(\s*\)\S.*$/\1/p" ${YAML_FILE})
  ((TOP_LEVEL_KEY_INDENT_FOUND++))    # have to set it, otherwise if TOP_LEVEL_KEY_INDENT
                                      # holds 0 spaces, it can not be examined as it was set
                                      # or not
  if [ $DEBUG ]; then  
    echo -n "[DEBUG]    TOP_LEVEL_KEY_INDENT: "
    echo -e "|${TOP_LEVEL_KEY_INDENT}|${#TOP_LEVEL_KEY_INDENT}"
  fi
}

# Set array of lines on which tasks were found:
#
#   Usage: get_task_lines YAML_FILE
#
#   Variables:
# 
#      $YAML_FILE         file to parse
#      $TASK_LINES[]      array of lines
#      $TOP_LEVEL_INDENT  tasks identation learned from the top level key
#
function get_task_lines() {
  
  YAML_FILE=${YAML_FILE:-$1} 
  test -n "${TOP_LEVEL_KEY_INDENT_FOUND}" || get_top_level_key_indent
  test "$YAML_FILE" || { echo "get_task_lines: missing file name to parse"; exit; }

  # Maybe it is better here to get things done without array?
  # files[$YAML_FILE]=( lines... )
  #grep -n -e "^${TOP_LEVEL_INDENT}- *[[:alnum:]]" ${YAML_FILE} | awk -F: '{print $1}' 
  #exit
  TASK_LINES=( $( grep -n -e "^${TOP_LEVEL_INDENT}- *[[:alnum:]]" ${YAML_FILE} | awk -F: '{print $1}' ) )
}
