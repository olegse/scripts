#!/bin/bash
#
#   get directory names from pgrep
#   display port via package json
#   just if not under base_dir ignore

list_apps() {
  echo "v: $v"
}

test "$1" == "-v" && ((v++))
echo "v: $v"
list_apps
