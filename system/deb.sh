#!/bin/bash
#
# Operate on a package owner

file=$( which $1 )
if [ -z "$file" ]
then
  echo "no file found"    # here proceed with find maybe
  exit 1
fi
shift

owner=$( dpkg -S $file | cut -d : -f 1  )
echo "owner: $owner"
case $1 in
  --only-upgrade)
    sudo apt install --only-upgrade $owner;;
  --remove)
    sudo apt remove --only-upgrade $owner;;
  *)
    echo "Option was not understood";;
esac
