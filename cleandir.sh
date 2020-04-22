#!/bin/bash
# -----------------------------------------------------------------------------
#
# This script is used to delete files (backups, logs, etc) that are more than
# NUM days old (defaults to 30) from the current date. We typically run this
# from a cron job or as the last step in a daily/weekly processes.
#
# NOTE: This script depends on lsdate being installed
#
# Examples:
#
# Keep only the last 90 days of kim logs
#
#   cleandir.sh /opt/arc/kim/logs 90
#
# Crontab entry to keep only the 7 days of ged work files
#
#   # cleanup ged work dir every morning at 1:02 am, keep only last 7 days of work files
#   2 1 * * * /opt/arc/bin/cleandir.sh /opt/arc/ged/work 7 >> /var/log/arc.log 2>&1
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

#         dir  number-of-retention-days
_cleandir "$1" "$2"

