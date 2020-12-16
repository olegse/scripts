#!/bin/bash
#
# Parse ansible --version directives and show the path

if [ $# -eq 0 ]
then 
  ansible --version | awk -F= '{print $1}'
else
  field=$1
  ansible --version | awk -F= '{ if ( $1 ~ /^ *'"$field"'/ ) print $2 }' | grep -o  '\(\/[-a-zA-Z_0-9.]*\)\+'
fi
