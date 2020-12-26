#!/bin/bash
#
# List image directory

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
  echo "  -c		print containers <-> images"
  echo "  -p		print image path"
  echo "  -h		print this message and exit"
  exit 0
}

# Prints image path. Expects 
# image id. path should be set globally.
function print_image_path() { find $path -name ${1}; }

# Print full path to the storage directory.
function print_storage_dir() { 
  if [[ -n  "$1" && "$1" -gt 0 ]]
  then
    echo "$path"
  else
    echo "The image storage directory:   $path (`stat -c "%U %G" $dir`)"
  fi
  exit 0
}
	

# Construct the path
dir=$( docker info | awk -F: '/Docker Root Dir/ {print $2}' )
driver=$( docker info | awk -F: '/Storage Driver/ {print $2}' | tr -d ' ' )
path=${dir/ /}/image/$driver/imagedb/content/

while getopts ":pcdqh" opt; do
  case $opt in
    c)	(( list_containers++ )) ;;  # create a function
    p)	(( print_image_path++ )) ;; # create a function
        # output:
        #
    d)  (( print_storage_dir++ )) ;;
    q)  (( quiet++ )) ;;
    h)  usage;;
    \?)  echo "`basename $0`: invalid option -- '$OPTARG'"
          exit 3;;
  esac
done
 
if [ -n "$print_storage_dir" ]
then
    print_storage_dir "$quiet" 
fi

# Test for permissions
test -r $dir || { echo "Cannot access '$dir'. Permission denied."; exit 2; }

# Display names along to files ${container:-a}
if [ -n "$list_containers" ]; then
	for name in $( docker ps -a --format "{{ .Names }}" )
	do
		image_id=$( docker inspect $name --format "{{ .Image }}" ) # expected:
                                          # sha256:d6e46aa2470df1d32034c6707c8041158b652f38d2a9ae3d7ad7e7532d22ebe0
		image_id=${image_id/*:}   # remove 'sha256' part
                              #     d6e46aa2470df1d32034c6707c8041158b652f38d2a9ae3d7ad7e7532d22ebe0
		repotag=$( docker inspect $image_id -f "{{ .RepoTags }}" )  # alpine:test and what about multiple values?
    echo "$name: " `print_image_path $image_id` "($repotag)"
    #keen_zhukovsky:  /var/lib/docker/image/overlay2/imagedb/content/sha256/d6e46aa2470df1d32034c6707c8041158b652f38d2a9ae3d7ad7e7532d22ebe0 ([alpine:latest])

	done             

elif [ -n "$print_image_path" ]; then
	for image_id in $(docker images --no-trunc --quiet)
	do
	 # echo "[DEBUG] Processing '$image_id'"
	 # learn tag
	 repotag=$( docker inspect $image_id -f "{{ .RepoTags }}" )
	 find $path -name ${image_id/*:} -exec echo -e "{}\n($repotag)" \; # remove 'sha:' part
	done
fi

# All the containers by image
# add interactive
#echo "Image path: '$path'"
#sudo ls -l $path
