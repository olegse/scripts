# Issue select to operate on apps
list_running_apps() {
    
  # Currently show only running apps
  declare -a apps=$( sudo netstat -t4 -nl -p | awk  '/node\s*$/ { print $NF }' | cut -d/ -f1 )

  for app in ${apps[@]}
  do
    sudo ps -p $app -o cmd | tail -n +2 | sed 's,.*/\(\w\+\)/node_modules.*,\1,'
  done
}
