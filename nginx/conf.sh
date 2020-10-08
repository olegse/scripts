#!/bin/bash
#
# Manipulate nginx configuration files

function usage() 
{
  echo "Usage: `basename $0` [-icv] [FILE...]"
  echo "List configuration and included files."
  echo "  -c    print main configuration file path"
  echo "  -i    print included files"
  echo "  -v    print also names of including files"
  # error code
  exit 0
}

# -c
NGX_CONF=$( nginx -V 2>&1 | sed -n 's/.*conf-path=\(\S*\).*/\1/p' )

# -i [FILE]...    list all included files

while getopts ":ci" opt
do
  case $opt in
    c)  # Display config file path
        echo "Nginx config file: '$NGX_CONF'"
        exit 0;;

    i)  # List included files
        #for FILE in ${CONF_FILES[@]}
        for file in $( awk '/^[^#]*include/ { print $2 }' $NGX_CONF | tr -d ';' )
        do
          echo "$file"
        done
        ;;

    \?) # Wrong option found
        echo "Invalid option \`-$OPTARG'"
        usage;;
  esac
done
