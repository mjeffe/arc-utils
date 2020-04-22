#!/bin/bash
# ---------------------------------------------------------------------------
# $Id$
# ---------------------------------------------------------------------------

USAGE="
Create a user on an ARC CentOS box, with default settings
usage: `basename $0` [-h] [--dry-run]
with --dry-run it will echo the commands but not run them
"

if [ "$1" = "-h" ]; then
   echo "$USAGE"
   exit
fi
dry_run=
if [ "$1" = "--dry-run" ]; then
   dry_run=TRUE
fi



echo
echo "$USAGE"

if [ `whoami` != 'root' ]; then
   echo "You must be root to run this script"
   exit
fi


# verify arc group exists
arc_group=`grep '^arc:' /etc/group`
if [ -z "$arc_group" ]; then
   read -p "No group named 'arc' exists.  Should I create it? [y/N] " answer
   if [ $answer = 'y' -o $answer = 'Y' ]; then
      if [ -n "$dry_run" ]; then
         echo "dry run:"
         echo "groupadd arc"
      else
         groupadd arc
      fi
   else
      echo "quitting..."
      exit
   fi
fi

echo
read -p "User's username: " username
echo
read -p "User's full name: " full_name
echo 
read -p "Users's password: " password
echo
#read -p "CSV list of additional groups: " adl_groups
#echo


# create user
if [ -n "$dry_run" ]; then
   echo "dry run:"
   echo "useradd -n -g arc -c \"ARC - $full_name\" -m $username"
   echo "echo \"$password\" | passwd --stdin $username"
   echo "chage -d 0 $username"
   #echo "usermod -a -G \"$adl_groups\" $username"
   echo "echo \"umask 002       # make files read/write-able by group\" >> /home/$username/.bashrc"
else
   useradd -n -g arc -c "ARC - $full_name" -m $username
   echo "$password" | passwd --stdin $username
   chage -d 0 $username
   #usermod -a -G "$adl_groups" $username
   echo "umask 002       # make files read/write-able by group" >> /home/$username/.bashrc
fi


