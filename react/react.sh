#!/bin/bash
# Automates repetative React tasks.
#
# List applicaitons in SELECT
# 
usage() {
  echo "Usage: `basename $0` [-v] [-c APP]|[-p [PORT] [APP]]|[-l] [APP]..."
  echo "Automates repetative React tasks. Supported tasks: "
  echo ""
  echo "   list applications"
  echo "   create new application"
  echo "   change/display port"
  echo ""
  echo "  -l        list current applications"
  echo "  -p [PORT] [APP]    print or set a port number"
  echo "  -c APP     create new app"
  echo "  -v         print what was done"
  echo "  -h         print this usage and exit"
  echo ""
  exit 0
}

declare -A apps             # apps[NAME]=APP_DIR
declare -A ports            # ports[NAME]=PORT
declare -A apps_running     # apps_running[PORT]=PID
declare -a app_dirs         # full path to the directories
declare -g APP_DIR
BASE_DIR=/var/node/ArtApps
RUN_MSG="\e[42m [RUNNING] \e[0m"
PORT_DEFAULT=3000


# Sets real directory for the application. The resulting is
# APP_DIR and APP_JSON
set_app() {

  # APP_DIR was passed as an argument
  test -z "$1" || APP_DIR=$1

  # If APP_DIR was not set, find it relation to the directory from
  # which the script is called.
  test -e "${APP_DIR:=$PWD}" || \
    {
      #echo "Relative directory: $APP_DIR";
      # Parse by application name
      # find . -maxdepth 2 -name "package.json" -exec grep --files-with-matches -e "nice_app" {} \;
      APP_DIR=$BASE_DIR/$APP_DIR;
    }
  test -e "$APP_DIR" || \
    { 
      #echo "Cannot change to '$APP_DIR', searching for application directory";
      APP_DIR=` find $BASE_DIR -maxdepth 2 -name "package.json" -exec grep --files-with-matches -e "nice_app" {} \; `
    }

  test -e "$APP_DIR" || { echo "No matching applications found"; exit 2; }

  # it's also another option when you pass just a name of the application
  # not full path

  APP_DIR=${APP_DIR#$BASE_DIR/}     #  now only path from the base directory
  APP_DIR=${BASE_DIR}/${APP_DIR%%/*} #  only top level directory name of the application

  if [ -n "$DEBUG" ]; then
    echo "[DEBUG] In $FUNCNAME"
    echo "[DEBUG] Processing APP_DIR: $APP_DIR"
  fi

  if [ ! -e "$APP_DIR/package.json" ]
  then
    unset APP_JSON
    return
  fi

  APP_JSON=$APP_DIR/package.json
  test "$DEBUG" && \
    echo "[DEBUG] APP_JSON was set to $APP_JSON"

  #  initialize application name
  APP_NAME=$( sed -n '/^[^:]*name\W*/ {s///; s/".*//gp}' $APP_JSON )
  test "$DEBUG" && \
    echo "[DEBUG] APP_NAME was set to $APP_NAME"

  # initialize application port
  get_port    # sets an APP_PORT

  # Now find PID of the processs that opened the PORT
  #netstat -t4 -nl -p 2>/dev/null | awk  '/node\s*$/ { if( $4 ~ /\<'"$APP_PORT"'\>/) print $NF }' | cut -d/ -f1
  APP_PID=`netstat --tcp -4 \
                    --numeric \
                    --listening \
                    --programs 2>/dev/null | awk  '/node\s*$/ { if( $4 ~ /\<'"$APP_PORT"'\>/) print $NF }' | cut -d/ -f1`

  test -n "$DEBUG" && \
    echo "[DEBUG] APP_PID was set to $APP_PID"
}

# Set apps[], ports[] and apps_running[]
init_apps() {

  # Operate on current directory by default
  test "$APP_DIR" = "$BASE_DIR" && \
    {
      echo "Please specify APP_NAME explicitly or ";
      echo "navigate to the one of the application directories."
      # run select here?
      exit 1
    }

  if [ -n "$DEBUG" ]
  then
    echo "[DEBUG] In $FUNCNAME"
    for i in ${!app_dirs[@]}
    do
      echo "$i: ${app_dirs[$i]}"
    done
  fi

  for APP_DIR in ${app_dirs[@]}; do 

    test -n "$DEBUG" && \
      echo "[DEBUG] $FUNCNAME: Processing APP_DIR: $APP_DIR"

    set_app   # for each application set:
              #  APP_DIR, APP_JSON, APP_PORT

    if [ -n "$DEBUG" ]
    then
      test -n "$APP_JSON" || { echo "Not an application directory... continuing..."; }
    fi
    test -n "$APP_JSON" || continue

    apps[$APP_NAME]=$APP_DIR
    ports[$APP_NAME]=$APP_PORT  # name <-> port

    if [ -n "$APP_PID" ] # process matching port found 
    then # verify that process started in the same directory where package.json <-> APP_PORT found
      if ps -p $APP_PID -o cmd | tail -n +2 | grep -q "$APP_DIR"
      then   
       # application is running for sure
       apps_running[$APP_NAME]=$APP_PID    # store it's pid
      fi
    fi
  done
}


# Prints current or sets new port in package.json of the application. Stored
# in APP_JSON.
get_port() {

  APP_PORT=`sed -n 's/^.*start.*"PORT=\([0-9]\+\).*/\1/p' $APP_JSON`
  if [ -z $APP_PORT ]; then APP_PORT=$PORT_DEFAULT; fi

  test -n "$DEBUG" && { \
    echo "[DEBUG] In $FUNCNAME"
    echo "[DEBUG] APP_PORT was set to $APP_PORT"
  }
}

# Write new or display current port number. Function can be optionaly passed 
# a port value.
write_port() {
    test -n "$1" || PORT=$1
    test -n "$PORT" || { echo "[ERROR] Port value is missing"; exit 2; }
    sed -i '/^ *"start"/ s/: ".*\(react-scripts.*\)/: "PORT='$PORT' \1/' $APP_JSON
    test $? = 0 && echo "Port was changed to: $PORT"
}

# Retrieve or set application port
port() {
  
  test "$DEBUG" && \
    echo "[DEBUG] In $FUNCNAME"

  if [ -z "$APP_JSON" ]
  then
    echo "No React application in '$APP_DIR'"
    exit 2
  fi

  if [ -n "$PORT" ] 
  then
    write_port $PORT 
  else
    echo $APP_PORT
  fi
}

# Start application
start() {
  cd $APP_DIR
  echo "Starting in $APP_DIR"
  npm start 
}

# Process all applications in loop
# suggested: process apps

# List applications, only running unless -v (for verbose) is specified
list_apps() {


  test -n "$DEBUG" && \
    { echo "[DEBUG] in $FUNCNAME";
      echo "[DEBUG] verbose: $verbose";
    }

  if [ -n "$verbose" ]
  then
    test -n "$DEBUG" && \
      echo "[DEBUG] reporting all apps"

    for app in ${!apps[@]}
    do
      echo -e "$app [${apps[$app]}] -> ${ports[$app]} ${apps_running[$app]:+$RUN_MSG}"
              # APP_NAME    APP_DIR          APP_PORT       name <-> pid
    done
  else 
    for app in ${!apps_running[@]}
    do
      echo -e "$app ${ports[$app]}"    # name port
        # was retrieved only under current user -> remember!
    done
  fi
}

# Create React app
create_react_app() {
  test -n "$1" || { echo "Application name must be specified"; exit 2; }
  cd $BASE_DIR
  echo "Creating `realpath $1`"
  npx create-react-app $1
  exit  # exit after creation
}

# Unrecognized option
error_opt() {
  echo "Unrecognied option: '-$1'"
}

# Parse options
while [ -n "$1" ]
do
  case "$1" in
    # show or set the port
    -p) 
        # Define quick function to check if the argument is port or 
        # application name
        is_numeric() {
          if [[ $1 =~ ^[0-9]+$ ]]   # arg is numeric
          then
            return 0
          fi
          return 1
        }
        shift

        # Test further arguments until it's not an option
        while [[ -n "$1" && ! "$1" =~  ^- ]]; do
          if is_numeric $1 
          then
            PORT=$1 
          else
            app_dirs=$BASE_DIR/$1   # BASE_DIR should be moved under set_app
          fi
          shift
        done

        action=port
        break;;

    -l) action=list_apps ;;

    # This will probably fail
    -s) test "$action" && \
            echo "Ignoring \`-s'" || action="start";;
    # Create new React app. APP_NAME required
    -c) create_react_app $2;;
        # create and exit
    -v) ((verbose++));;
    -h) usage;;
    -*) error_opt "$1";;
     # here process all arguments as application names
     *) app_dirs+=( $1 );;  # combine test above 
  esac
  shift   # next argument
done

if [ -z "$action" ] 
then
  test -n "$DEBUG" && \
    echo "Performing default action"

  action=list_apps
  ((verbose++))   # always verbose
elif [ $action == "list_apps" ]
then
  #test -n "$DEBUG" && \
    #find . -maxdepth 1 -type d -not -name ".*" -exec realpath {} \;
  if [ -z "$app_dirs" ]
  then
    cd $BASE_DIR
    app_dirs=( $( find . -maxdepth 1 -type d -not -name ".*" -exec realpath {} \; ) )
  else
    ((verbose++))   # application directories or names were specified explicitely <- always verbose
  fi
fi
# Process current directory by default
test -n "$app_dirs" || app_dirs=$PWD
init_apps   # no app_dirs[] use the $PWD
$action
