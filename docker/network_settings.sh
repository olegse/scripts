#!/bin/bash
#
# Display container network settings
test $1 || { echo "`basename $0` CONTAINER_NAME_OR_ID"; exit 1; }

docker inspect "$1" -f "{{json .NetworkSettings}}" | grep -o "\(NetworkID\|IPAddress\)[^,]\+" | sed -n '/NetworkID/,/IPAddress/ {s/"//; s/:/: /gp}'
