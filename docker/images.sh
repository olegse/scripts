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
function usage() {
  echo "Usage: `basename $0` [-d] [IMAGE...]"
  echo "List image files filtered with IMAGE or all the images."
  echo "Options:"
  echo "  -d            print image dir path"
  exit 0
}


# Construct the path
dir=$( docker info | awk -F: '/Docker Root Dir/ {print $2}' )
driver=$( docker info | awk -F: '/Storage Driver/ {print $2}' | tr -d ' ' )
path=$dir/image/$driver/imagedb/content/


while getopts d opt; do
  case $opt in
    'd')  echo "The image storage directory:   $path (`stat -c "%U %G" $dir`)"
          exit 0;;
    'h')  usage;;
    '?')  echo "`basename $0`: invalid option -- '$OPTARG'"
          exit 3;;
  esac
done
 
if ! test -r $dir   
then 
  echo "Cannot access '$dir'. Permission denied."
  exit 2
fi

for image_id in $(docker images --no-trunc --quiet)
do
  echo "[DEBUG] Processing '$image_id'"
  find $path -name ${image_id/*:} -exec file {} \;
done

# add interactive
#echo "Image path: '$path'"
#sudo ls -l $path
