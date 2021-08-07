#!/bin/bash
#
# netstat(1) wrapper
#
proc=$1
if [ -z "$proc" ]; then echo "No program name specified"; exit; fi
echo "Parsing for '$proc'"
sudo netstat -antpl | sed -n '/'$proc'/ s/.*:\([0-9]\+\).*:.*\s\([0-9]\+\).*/\1 <=> \2/'
