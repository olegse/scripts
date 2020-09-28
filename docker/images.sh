#!/bin/bash
#
# List image directory

# -d    display image dir

# without arguments display all the files related to image ID's
# in turn:
#   /var/lib/docker/image/overlay2/imagedb/content/sha256/4bb46517cac397bdb0bab6eba09b0e1f8e90ddd17cf99662997
#
# or with --no-trunc
#   /var/lib/docker/image/overlay2/imagedb/content/sha256/4bb46
#
# or with --names
#   /var/lib/docker/image/overlay2/imagedb/content/sha256/[nginx]


# Construct the path
dir=$( docker info | awk -F: '/Docker Root Dir/ {print $2}' )
driver=$( docker info | awk -F: '/Storage Driver/ {print $2}' )

if ! test -r $dir 
then 
  users=( $( stat $dir -c "%U %G" ) )
  echo "Run as ${users[0]} or as part of ${users[1]} group."
fi
path=$dir/image/$driver/imagedb/ #content/

# Here loop through all the images or only those found on command line
test -z "$1" || { find $path -name "*$1*" -exec file {} \; ; exit; }

# add interactive
#echo "Image path: '$path'"
#sudo ls -l $path
