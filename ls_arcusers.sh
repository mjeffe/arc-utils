#!/bin/bash
# ---------------------------------------------------------------------------
# list ARC users - can be usefull for sending email, etc.
# ---------------------------------------------------------------------------

usage() {
   echo "prints all ARC usernames"
   echo "usage: `basename $0` [-unh] [username1, username1, ...]"
   echo "options:"
   echo "   with no options, prints all usernames"
#   echo "   -u    prints usernames (default)"
   echo "   -n    prints Full Name for users listed on command line"
   exit
}

get_users() {
   field=$1
   grep -e ':ARC - ' /etc/passwd | cut -d: -f $field
}


#while getopts "unh" opt; do
#   case $opt in
#      #d ) BKUP_DIR=$OPTARG;;
#      u ) get_users 1 ;;
#      n ) get_users 5 ;;
#      h ) usage;;
#      * ) echo "invalid option..."
#          exit;;
#   esac
#done
#shift $(($OPTIND - 1))
#if [ "$#" -eq 0 ]; then
#   grep -e ':ARC - ' /etc/passwd | cut -d: -f1
#   #echo "missing username"
#fi

grep -e ':ARC - ' /etc/passwd | cut -d: -f1



