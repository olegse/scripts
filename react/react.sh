#!/bin/bash
# Automates repetative React tasks.
#
# List applicaitons in SELECT
# 
# TEST TEST TEST ArtApps in Friday
usage() {
  echo "Usage: `basename $0` [-c APP] | [-p [PORT] [APP]] "
  echo "Automates repetative React tasks. Supported tasks"
  echo "are: list current configuration,  create new application or change/display current port."
  echo ""
  echo "  -l        list current applications"
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

# First we need to find a top level directory of the given project. That can
# be or passed explicitely on the command line or found in relation to the directory
# from which the script is called.
app_dir() {
  APP_DIR=${PWD#$BASE_DIR/}
  APP_DIR=${APP_DIR%%/*}
  APP_DIR=$BASE_DIR/$APP_DIR
  APP_JSON=$APP_DIR/package.json
  if ! test $APP_JSON; then
    echo "packge.json is missing?"
    exit 2; 
  fi
}

# Expects package.json 
get_port() {
  echo "Searching for port in '$APP_JSON'"
  APP_PORT=`sed -n 's/^.*start.*"PORT=\([0-9]\+\).*/\1/p' $APP_JSON`
  echo ${APP_PORT:=3000}    # DEBUG
}

# Write new or display current port number. Function can be optionaly passed 
# a port value.
port() {
  if ! [ -n "$1" ]      # no port number
  then
    PORT=`sed -n 's/^.*start.*"PORT=\([0-9]\+\).*/\1/p' $PJ`
    if [ -z "$PORT" ]; then
      PORT=3000     # default port
    fi
    echo "Port number: $PORT"
  else  # set the port number
    PORT=$1
    sed -i '/^ *"start"/ s/: ".*\(react-scripts.*\)/: "PORT='$PORT' \1/' $PJ
    echo "Port was changed to: $PORT"
  fi
}

# List available applications
list_apps() {
  cd $BASE_DIR    # start from the base directory
  declare -A apps
  declare -A apps_running
  # actually search by package.json till first found...
  declare -a app_dirs=$( find . -maxdepth 1 -type d -not -name ".*" -exec realpath {} \; )
  # Process each application directory in turn
  for APP_DIR in ${app_dirs[@]}; do
    echo "<<<<<<<<>>>>>>>>>"
    echo "APP_DIR: $APP_DIR" 
    # find application names
    APP_JSON=$APP_DIR/package.json
    if [ -e "$APP_JSON" ]; then
      echo "Getting app_name"
      APP_NAME=$( sed -n '/^[^:]*name/ {s///; s/\W//gp}' $APP_JSON )
      get_port    # returns in APP_PORT
      echo "$APP_NAME: $APP_PORT"
      apps[$APP_NAME]=$APP_PORT
      # Find PID by port
       netstat -t4 -nl -p | awk  '/node\s*$/ { if( $4 ~ /\<'"$APP_PORT"'\>/) print $NF }' | cut -d/ -f1
       APP_PID=`netstat -t4 -nl -p | awk  '/node\s*$/ { if( $4 ~ /\<'"$APP_PORT"'\>/) print $NF }' | cut -d/ -f1`
       #unset APP_PORT
       echo "APP_PID: $APP_PID"
       if [ -n "$APP_PID" ]; then
         if ps -p $APP_PID -o cmd | tail -n +2 | grep -q "$APP_DIR" --color 
         then
          apps_running[$APP_NAME]=$APP_PID 
          echo "App $APP_NAME is running"
        fi
       fi
    fi
 
    echo "<<<<<<<<>>>>>>>>>"
  done
  
  # Report apps status
  for app in ${!apps[@]}; do
    echo "$app -> ${apps[$app]} ${apps_running[$app]:-}"
                                                #    :+
  done
}

# Issue select to operate on apps
list_running_apps() {
    
  # Currently show only running apps
  declare -a apps=$( sudo netstat -t4 -nl -p | awk  '/node\s*$/ { print $NF }' | cut -d/ -f1 )

  for app in ${apps[@]}
  do
    sudo ps -p $app -o cmd | tail -n +2 | sed 's,.*/\(\w\+\)/node_modules.*,\1,'
  done
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
fi

# Parse options
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
          if [ -z "$PORT" ]     # why? shall I pass it somewhere?
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

      # move to the application directory if specified
      cd ${APP_DIR:-.} 2>/dev/null || { echo "Can not find application directory."; exit 5; }      
      test "$APP_DIR" =  "$BASE_DIR" && \
        {
          echo "Please specify APP_NAME explicitly or ";
          echo "navigate to the one of the application directories."
          # run select here?
          exit 1
        }
      # find application directory from the current one or the one that was specified
      app_dir
      port $PORT
      ;;
  -l) list_apps ;;
  # Create new React app. APP_NAME required
  -c) create_react_app $2;;
  -h) usage;;
  -*) error_opt "$1";;
   *) usage;;  # combine test above
esac
