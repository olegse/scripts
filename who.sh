if ! test -r $dir   # still has an issue, file cannot be readable by group
then 
  users=( $( stat $dir -c "%U %G" ) )
  echo "Run as ${users[0]} or as part of ${users[1]} group."
fi
