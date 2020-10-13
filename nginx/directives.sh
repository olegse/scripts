#!/bin/bash
# 
# Just an example, not the best solution.

# Grep through all the included files
declare -a files=$( nginx -T 2>&1 | sed -n 's,# configuration file \(\(\/[a-zA-Z_.]\+\)\+\).*,\1,p' )
for config in ${files[@]}
do
  echo "config: $config"
   #awk '/^\s*server/ {print NR " " $0}' $config
done

# Fuck ed(1)
