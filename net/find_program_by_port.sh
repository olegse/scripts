#!/bin/bash
#
# Find program that uses a port
test "$1" || { echo "Specify a port"; exit 1; }
port=$1
sudo netstat -anpl -t4 | awk '{ if( $4 ~/\<'$port'\>/) print }'
