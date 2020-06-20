#!/bin/bash
#
# Add a "shabang" string and make a script executablecutable
function usage { echo "`basename $0` -e <exe> -f <script>"; exit 1; }
# From the other side, check for the script suffix and initialize the executablecutable
# accordingl
# Here add getopt

while getopts ":e:f:" option; do
  case $option in 
    e) executable=$OPTARG;;
    f) script=$OPTARG;;
    \?) echo "Invalid option: '$OPTARG'";;& # test following clauses to jump over ':' and hit usage()
    ':') echo "Option '-$OPTARG' requires an argument'";&  # will trigger usage anyway
    *) usage;;
  esac
done
executable=`which ${executable}`
#sed -i.backup '1 i #!'"$(which $2)" $1
#chmod 755 $1
