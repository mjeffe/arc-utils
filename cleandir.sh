#!/bin/bash
# -----------------------------------------------------------------------------
#
# this script is meant to delete backups that are more than 30 days old from
# the current date.
#
# NOTE: This script depends on lsdate being installed
# -----------------------------------------------------------------------------

this=`basename $0`
LSDATE=/usr/local/bin/lsdate

_cleandir() {
   dir="$1"
   retention_days="$2"
   if [ -z "$retention_days" ]; then
      retention_days=30
   fi
   if [ -z "$dir" ]; then
      echo "$this: dir parameter is empty, skipping..."
      return
   fi
   if [ ! -d "$dir" ]; then
      echo "$this: $dir does not exist, skipping..."
      return
   fi
   cd $dir
   dt=`date | perl -ne 'chomp; print'`
   echo "$dt: cleaning up $dir"
   #echo "$LSDATE -g $retention_days | xargs -i rm -vf '{}'"
   $LSDATE -g $retention_days | xargs -i rm -vf '{}'
}



if [ -z "$1" ]; then
   echo "description: removes all files in directory, older than retention_days"
   echo "usage: `basename $0` dir [retention_days]"
   exit 1
fi

_cleandir "$1" "$2"

