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


# SEARCHING for image id 
# for each container in if field 2 eq image id print
# Display names along to files ${container:-a}
image_id=$1
# more confident always translate image repo to image id with sed
# , so we ensure it is a match
#docker ps -a | awk '{ if( $2 ~ /'$image_id'/ ) print $NF " " $1 }'
#docker rm $( docker ps -a | awk '{ if( $2 ~ /'$image_id'/ ) print $NF }' )

# Run the prompt before or with -f
