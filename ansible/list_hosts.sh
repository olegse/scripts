#!/bin/bash
#

#source scripts/ansible.sh

# Current work
#
# --hostvars
function hostvars() {
  ansible ${HOSTS} --setup 
# Prints all the variables that are set from the host_vars/* or
# group_vars/* files that gonna be set for this hosts specification.
#function list_host_vars() {

# Sets INVENTORY to the inventory file, by parsing `ansible --version` command.
function init_inventory() {
  INVENTORY=$( awk -F= '/inventory/ {print $2}' \
              `ansible --version 2>/dev/null | awk -F= '/config file/ {print $2}'` )
}

#
# Ensure that INVENTORY is set.
#
function ensure_inventory() 
{
  test -n "${INVENTORY}" || init_inventory
  test -n "${INVENTORY}" || \
  {
    echo "Inventory file was not found. Please specify it explicitly with \`--inventory' option.";
    exit 1;
  }
}

#
# Expand hosts pattern
#
function expand_hosts_pattern() {
  ensure_inventory    # set INVENTORY 
  if [ "$PLAYBOOK" ]
  then 
    #PLAYBOOK=$WORKDIR/$PLAYBOOK
    ansible-playbook ${PLAYBOOK} --list-hosts --limit $HOSTS \
          2>/dev/null | sed -n '/hosts/,$ {/hosts/d;p}'
  else
    ansible --list-hosts $HOSTS  \
          2>/dev/null | sed -n '/hosts/,$ {/hosts/d;p}'
  fi
}

# Print out host line from the inventory file.
#   --list-host-inventory --hosts HOSTS
#
# Desired output:
# [group]  host
#          var <-> value
#
function list_hosts_inventory() {
  hosts=$( expand_hosts_pattern )
  for host in $hosts
  do
    grep $host $INVENTORY
  done
}

# DEFAULT ACTION

# Expand and print hosts pattern
function list_hosts() {
  expand_hosts_pattern
}

# Expand hosts pattern and print host group
# following by the hostname
function list_hosts_verbose() {
  hosts=$( expand_hosts_pattern )
  for host in $hosts
  do
    group=$( get_host_group )
    echo "[$group]  -> $host"
  done
}

# List all the groups in the inventory file
function list_inventory_groups() {
  ensure_inventory
  grep '^\s*\[' $INVENTORY
}

# Prints inventory file location
function print_inventory() {
  ensure_inventory
  echo "Inventory file:    $INVENTORY"
}

# Edit inventory file
function edit_inventory() {
  ensure_inventory
  vi $INVENTORY
}

# Print usage and exit with the exit code of $1, otherwise 0.
function usage() {
  EXIT_CODE=${1:-0}
  echo "Usage: `basename $0` OPTION... [PLAYBOOK|INVENTORY] HOSTS"
  echo "Ansible parsing. Default is to expand a HOSTS pattern to matching hosts."
  echo ""
  echo "The hosts pattern can be specified either with \`--hosts' option or put"
  echo "last on the command line. If playbook file is provided the hosts pattern is read"
  echo "from it, if both hosts and playbook are specified, the playbook hosts"
  echo "will be filtered through a pattern found on the command line. If hosts pattern was "
  echo "omited it defaults to \`all'."
  echo ""
  echo "  --list-hosts                 list hosts that matches pattern (working)"
  echo "  --list-hosts-inventory       list line in inventory for each host"
  echo "  --list-hosts-vars            list all the variables that will apply on the"
  echo "                               host within host_vars/* and group_vars/*"
  echo "  --hosts HOSTS                hosts pattern"
  echo "   -p,--play[book]             playbook"
  echo "   -i                          print inventory file name"                
  echo "   -e, --edit-inventory        edit inventory file in place"                
  exit ${EXIT_CODE}
}

### MAIN ###

ACTION=list_hosts
HOSTS=all

WORKDIR=`pwd`

while [ "$1" ]; do
  case "$1" in 

    --list-hosts|-l)  # default
      action=list_hosts ;;

    --list-host-group|-g)   
      action=list_host_group ;;

    --list-hostvars|-h)
      action=list_hostvars ;;

    --list-host-inventory)
      action=list_host_inventory;;

    -i)
      action=print_inventory;;

    # Playbook to parse
    -p|--play|--playbook)
      shift; PLAYBOOK=$1;;

    # Hosts pattern; or specify it last on the 
    # command line without an option?
    --hosts)
      shift; HOSTS=$1;;

    -e|--edit-inventory)
      action=edit_inventory;;

    # GROUPS
    --list-groups)
      action=list_groups;;  # with playbook please
    --inventory)
      shift; INVENTORY=$1;;
    --group)
      shift; GROUP=$1;;
    --help|-h)
      usage 0;;
    *)
      echo "Unrecognized option \`$1'"
      # if there is more options -> error
      # otherwise this is the hosts pattern
      usage 1;;
  esac
  shift
done

test "$PLAYBOOK" && PLAYBOOK=./$PLAYBOOK

${ACTION}
