# Print array elements
function dump() {
  declare -n a=$1
  echo "${a[@]}"
  echo "${#a[@]}"
  for((i=0; $i < ${#a[@]}; i++))
  do
    echo "$i: '${a[$i]}'"
  done
}

