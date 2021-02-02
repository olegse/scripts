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
  echo "  -d    print image dir path"
  echo "  -c		print containers <-> images"
  echo "  -p		print image path"
  echo "  -h		print this message and exit"
  exit 0
}

# Prints image path. Expects 
# image id. path should be set globally.
function print_image_path() { find $path -name ${1}; }
	

# Construct the path
dir=$( docker info | awk -F: '/Docker Root Dir/ {print $2}' )
driver=$( docker info | awk -F: '/Storage Driver/ {print $2}' | tr -d ' ' )
path=$dir/image/$driver/imagedb/content/

while getopts ":pcdh" opt; do
  case $opt in
    c)	(( list_containers++ )) ;;
    p)	(( print_image_path++ )) ;;
    d)  echo "The image storage directory:   $path (`stat -c "%U %G" $dir`)"
          exit 0;;
    h)  usage;;
    \?)  echo "`basename $0`: invalid option -- '$OPTARG'"
          exit 3;;
  esac
done
 
# Test for permissions
test -r $dir || { echo "Cannot access '$dir'. Run under root; exit 2; }

# Display names along to files ${container:-a}
if [ -n "$list_containers" ]; then
	for cnt in $( docker ps -a --format "{{ .Names }}" )
	do
		image_id=$( docker inspect $cnt --format "{{ .Image }}" )
		image_id=${image_id/*:}
		repotag=$( docker inspect $image_id -f "{{ .RepoTags }}" )
		echo "$cnt:  $image_id ($repotag)"
		test "$print_image_path" && print_image_path $image_id

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

# add interactive
#echo "Image path: '$path'"
#sudo ls -l $path
