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
  echo "  -h    print this message and exit"
  # error code
  exit 0
}
# Print usage on no arguments
test -n "$1" || usage 

# Set nginx config path
# [!] another way is to filter through nginx -T
NGX_CONF=$( nginx -V 2>&1 | sed -n 's/.*conf-path=\(\S*\).*/\1/p' )

while getopts ":civh" opt
do
  case $opt in
    c)  # Display config file path
        echo "Nginx config file: '$NGX_CONF'"
        exit 0;;

    i)  # List included files
        #for FILE in ${CONF_FILES[@]}
        for file in $( awk '/^[^#]*include/ { print $2 }' $NGX_CONF | tr -d ';' )
        do
          if test -e $file; then ls $file; fi
        done
        # implement recursivity
        ;;

    v)  # be verbose
        ;;

    h)  usage;;


    \?) # Wrong option found
        echo "Invalid option \`-$OPTARG'"
        usage;;
  esac
done
