#!/bin/bash
# ---------------------------------------------------------------------------
# $Id$
#
# Remove an SFTP user that was created by the cr_sftpuser.sh script.
# ---------------------------------------------------------------------------

# defaults
GROUP=sftpusers
BASE_DIR=/sftp/home
USER_DIR=/home
DRYRUN=


# ---------------------------------------------------------------------------
# exit script with error message
# ---------------------------------------------------------------------------
die() {
   echo "$1"
   exit 1
}

if [ "$1" = "--dry-run" ]; then
   DRYRUN='echo'
   shift
fi

if [ `whoami` != 'root' ]; then
   die "You must be root to run this script"
fi

if [ -z "$1" ]; then
   die "usage: `basename $0` username1 [username2 ...]"
fi
user=$1

# check to see if user exists
user_exists=`grep ":${USER_DIR}/${user}:/sbin/nologin$" /etc/passwd`
if [ -z "$user_exists" ]; then
   die "Unable to find the user, or it does not look like an SFTP user"
fi
if [ -z "`echo $user_exists | grep SFTP`" ]; then
   die "User does not look it was created by the mk_sftpuser.sh script, aborting..."
fi

read -p "This will remove the sftp user $user and user's entire home directory structure! Continue? [yN] " ans
if [ "$ans" = "Y" -o "$ans" = "y" -o "$ans" = "yes" ]; then
   :
else
   die "aborting $user..."
fi

#$DRYRUN userdel -r -R $BASE_DIR $user   # can't get this to work
$DRYRUN userdel -r $user >/dev/null 2>&1
$DRYRUN rm -fr $BASE_DIR/$user

