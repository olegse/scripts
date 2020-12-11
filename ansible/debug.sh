#!/bin/bash
#
# printl

# Print line or range of lines
#
#   Usage: printl FILE START [END]
# 
function printl() {
  FILE=$1; START=$2; END=$3

  if [ $DEBUG ]; then
    echo "[DEBUG] in printl(): "
    echo "	\$YAML_FILE:   $YAML_FILE"
    echo "	\$START: $START"
    echo "	\$END:   $END"
  fi

  if [ "$3" ]   # here expansion can be used ${3:=,$3} 
  then 
    cat -n $1 | sed -n "$2,$3p"
  else
    cat -n $1 | sed -n "$2p"
  fi
}

# Calls to printl(); The only difference is that YAML_FILE is implied 
# as a filename, but still can be passed as a first argument
function debug_block() {
  YAML_FILE=${YAML_FILE:-$1}
  BLOCK_START=${BLOCK_START:-$2}
  BLOCK_END=${BLOCK_END:-$3}
  if 
  ! [ "$YAML_FILE" ]
  then echo "debug_block: missing file name"; exit
  elif
  ! [ "$BLOCK_START" ]
  then echo "debug_block: missing block start address"; exit
  elif
  ! [ "$BLOCK_END" ]
  then echo "debug_block: missing block end address"; exit
  fi

  echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  printl $YAML_FILE $BLOCK_START $BLOCK_END
  echo "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
}
