#!/bin/bash
#
# List image directory

if [ -z "$1" ]; then docker images; fi
info=( $( docker info | awk -F: '/(Docker Root Dir)|(Storage Driver)/ {print $2}' ) )
path=${info[0]}/image/${info[1]}/imagedb/content/
ls -l $path
