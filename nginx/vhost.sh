#!/bin/bash
# 
# Just an example, not the best solution.


# Find the closes line number stored 
# in blocks relatively to passed line number
function find_closest_bracket() {
  server_line=$1
  for line in ${!blocks[@]}
  do  
    echo "[DEBUG] comparing $line <-> $server_line "
    if [ ${minline:=$line} -eq $server_line ]
    then
      break

    elif [ $line -lt ${minline} ]
    then
      minline=$line
    fi
  done

  echo "Block start and end for '$server_line': $minline <-> ${blocks[$minline]}"
}
    
# Populate servers[] with line ranges of server blocks
function get_server_block() {

  test -e "$1" || { echo "Usage: get_server_block NGX_CONF"; exit 3; }
  ngx_file=$1

  # Find 'server' blocks
  declare -a servers=$( awk -F: '/^ *server *{? *$/ {print NR}' $ngx_file )
  for server in ${servers[@]}
  do
    echo "server: $server"
    echo "close bracket to the server is "; find_closest_bracket $server
  done
}

# Next is to find closest bracket to the server directive, so what were the options
# to find a line number:
#
# 1. awk '/<pattern>/ {print NR}' FILE
function parse_blocks() {
    
  echo "\$1: $1"
  test -e "$1" || { echo "Usage: parse_blocks NGX_CONF"; exit 3; }
  ngx_file=$1
  declare -gA blocks
  declare -a open_brackets    # stores opening bracket line numbers
  j=0     # index of the next bracket pair in open_brackets[]
          # to be closed

  # Find line numbers of all the encountered brackets
  declare -a brackets=( $(awk '/{|}/ {print NR}' $ngx_file ) )

  # Examine found brackets
  for((i=0; $i < ${#brackets[@]}; i++))
  do
    if sed -n "${brackets[$i]} p" $ngx_file | grep -q '{'
    then  # openging bracket encountered
      open_brackets[$j]=${brackets[$i]};    # store line number
      (( j++ ))     # be ready to store next line number
    else  # closing bracket encountered
      blocks[${open_brackets[((--j))]}]=${brackets[$i]}
      echo "${open_brackets[$j]} <-> ${blocks[${open_brackets[$j]}]}  "
    fi
  done

  for start in ${!blocks[@]}
  do
    echo "$start <-> ${blocks[$start]}"
  done

  get_server_block "$ngx_file"

}

#find closest directive name to the bracket
function get_directive_name() {
  if [ directive=$( sed -n "$1 s/\(\w\+\).*/\1/p" $ngx_file ) ]
  then
    echo "Directive found: '$directive'"
  fi
}

# Find all the servers
# Only line ranges within server directive
# function display_server_info() on

#declare -a files=$( nginx -T 2>&1 | sed -n 's,# configuration file \(\(\/[a-zA-Z_.]\+\)\+\).*,\1,p' )
declare -a files=( ~/nginx/conf.d/default.conf )
for file in ${files[@]}
do
  echo "Processing '$file'..."
  parse_blocks $file
done
