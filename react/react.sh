#!/bin/bash
# Automates repetative React tasks.
#
# List applicaitons in SELECT
# 
usage() {
  echo "Usage: `basename $0` [-c APP] | [-p [PORT] [APP]] "
  echo "Automates repetative React tasks. Supported tasks"
  echo "are: list current configuration,  create new application or change/display current port."
  echo ""
  echo "  -p [PORT] [APP]    print or set a port number"
  echo "  -c APP     create new app"
  echo "  -h         print this usage and exit"
  echo ""
  echo "Port value is searched inside \"package.json\" file in the application directory."
  echo "PORT and APP are optional and can be used interchangabely. If port value is spesified"
  echo "it is set, otherwise the current value is displayed. If APP was passed to the option"
  echo "it is appended to the BASE_DIR (/var/node/ArtApps) to construct a full path to the APP_DIR, where"
  echo "\"package.json\" is searched and manipulated, otherwise, the current directory is taken to be"
  echo "inside a tree of application directories, where the file will be searched recursively."
  exit 0
}

BASE_DIR=/var/node/ArtApps

# Find directory in which package.json is located. Start
# searching in the current directory and upper directories until
# BASE_DIR is reached
find_pj() {
  PJ=   # will be initialized if found
  DIR=`pwd`   # set current directory value

  while [[ $DIR != ${BASE_DIR} ]] #echo searching in $DIR
  do
    #ls package.json
    if ls package.json &>/dev/null
    then
      PJ=package.json   # package.json file was found
      break             # do not check next directories
    else 
      : #echo not found;    # for debugging purposes
    fi
    DIR=$( dirname $DIR  )    # get parent directory name
    cd $DIR                   # navigate to parent directory
  done

  if [ -n "$PJ" ]; then       # package.json was found
    return 0    # return true
  else
    echo "package.json file was not found" 2>&1
    exit 2    # exit here
  fi
}

# Write new or display current port number. Function can be optionaly passed 
# a port value.
port() {
  if ! [ -n "$1" ]      # no port number
  then
    PORT=`sed -n 's/^.*start.*"PORT=\([0-9]\+\).*/\1/p' $PJ`
    if [ -z "$PORT" ]; then
      PORT=3000
    fi
    echo "Port number: $PORT"
  else  # set the port number
    PORT=$1
    sed -i '/^ *"start"/ s/: ".*\(react-scripts.*\)/: "PORT='$PORT' \1/' $PJ
    echo "Port was changed to: $PORT"
  fi
}

list_apps() {
    
}
# Create React app
create_react_app() {
  npx create-react-app $1
}

# Unrecognized option
error_opt() {
  echo "Unrecognied option: '-$1'"
}

# Print usage() on no args
if [ $# -eq 0 ]
then
  usage
else
  case "$1" in
    # show or set the port
    -p) 
        is_numeric() {
          if [[ $1 =~ ^[0-9]+$ ]]   # APP_NAME
          then
            return 0
          fi
          return 1
        }
        while [ -n "$2" ]; do
          if is_numeric $2; then
            if [ -z "$PORT" ]
            then
              PORT=$2
            else
              echo "Port was already set"
              exit
            fi
          else
            if [ -z "$APP_DIR" ]
            then
              APP_DIR=$2
            else
              echo "Applicaton was already specified"
              exit
            fi
            APP_DIR=$BASE_DIR/$2
          fi
          shift
        done
        
        test -n "$APP_DIR" || APP_DIR=$PWD
        test -d "$APP_DIR" || { echo "No such project: '$APP_NAME'"; exit 5; }
        echo "APP_DIR: $APP_DIR"
        echo "BASE_DIR: $BASE_DIR"
        test "$APP_DIR" =  "$BASE_DIR" && \
          {
            echo "Can not find application directory.";
            echo "Please specify APP_NAME explicitly or ";
            echo "navigate to the one of the application directories."
            exit 1
          }
        cd $APP_DIR
        find_pj
        port $PORT
        ;;
    # Create new React app. APP_NAME required
    -c) create_react_app $2;;
    -h) usage;;
    -*) error_opt "$1";;
     *) usage;;  # combine test above
  esac
fi
