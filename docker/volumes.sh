#!/bin/bash
#
# Find volume by container name.

test $1 || { echo "Volume name must be specified"; exit 1; }

# Will print actual folder on the filesystem
VOLUME=$( docker volume inspect $1 | awk -F: '/Mountpoint/ {print $2}' | sed 's/[",]//g' )
echo "Volume: $VOLUME"

# Find container by volume
# in each container match key name of Mounts.[0].Name against volume name
