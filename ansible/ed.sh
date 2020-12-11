# ED functions
#
#  find_upper_block_end        prints a line number of the upper (previous) block
#  write_tag                   append a tag to the block end
#
# Global variables:
#
#    YAML_FILE    yaml file that is parsed


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
NEXT_BLOCK_START=$1 
cat -n $YAML_FILE | sed -n "$BLOCK_START,${NEXT_BLOCK_START}p" | \
awk '/[-a-zA-Z0-9]/ {print $1}'
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
