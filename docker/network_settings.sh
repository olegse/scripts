#!/bin/bash
#
# Display container network settings
test $1 || { echo "`basename $0` CONTAINER_NAME_OR_ID"; exit 1; }

docker inspect "$1" -f "{{json .NetworkSettings}}" | grep -o "\(NetworkID\|IPAddress\)[^,]\+" | sed -n '/NetworkID/,/IPAddress/ {s/"//; s/:/: /gp}'
# here if you read container id, we can get all the containers 
# attached to the network

#docker inspect network NET_ID -f "{{json.Containers}}" |\
  #grep -o '\(Name[^,]\+\)' |\
  #sed 's/"//g'
