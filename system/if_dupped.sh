#test

declare -a a_1=( {a..f} )
declare -a a_2=( {a..f..2} )

iter() { 
  declare -n b_1=$1
  declare -n b_2=$2
  for f in ${b_2[@]}
  do
    if_dupped b_1 $f
    echo "returned from if_dupped: $?"
    echo "f: $f" 
  done
}
  
iter a_1 a_2
echo $?
