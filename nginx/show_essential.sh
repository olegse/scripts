#!/bin/bash
#
# 
                                  # maybe with awk will be better? :)
 for file in $(sudo nginx -T 2>&1 | sed -n 's,# configuration file \(\/[^ :]\+\):$,\1,p');
 do                                       # get all the configuration files here
   directives="$( grep '^\s*\(listen\|server_name\|root\)' "$file"; )"
   test "$directives" && { \
   echo "<<< $file >>>";
   echo "$directives";    # keeping spaces -> awesome!
   echo ;
 }
 done
