#!/bin/bash
#
# List image directory

# -dir    display image dir; with the image id, print
#         all directories in which image is located

# without arguments display all the files related to iamge ID's
# in turn:
#   /var/lib/docker/image/overlay2/imagedb/content/sha256/4bb46517cac397bdb0bab6eba09b0e1f8e90ddd17cf99662997
#
# or with --no-trunc
#   /var/lib/docker/image/overlay2/imagedb/content/sha256/4bb46
#
# or with --names
#   /var/lib/docker/image/overlay2/imagedb/content/sha256/[nginx]


# With test(1), if file readable... give more information about needed user
# or group.
[ $UID -eq 0 ]  || { echo "Run as root..."; exit 1; }

# Construct the path
info=( $( docker info | awk -F: '/(Docker Root Dir)|(Storage Driver)/ {print $2}' ) )
path=${info[1]}/image/${info[0]}/imagedb/ #content/

# Here loop throuugh all the images or only those found on command line
test -z "$1" || { find $path -name "*$1*" -exec file {} \; ; exit; }

# add interactive
#echo "Image path: '$path'"
#sudo ls -l $path
