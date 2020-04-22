#!/bin/bash
# ---------------------------------------------------------------------------
# Create a new sftp user to be used on an ARC jailed SFTP server
#
# This has a soft dependecy on 'diceware' for generating passwords. It will
# fallback to using an ugly random character generator if diceware is not found.
#
# To install diceware:
#   install pip (best to consult current docs, but this worked in 2018):
#      curl -O https://bootstrap.pypa.io/get-pip.py
#      sudo python ./get-pip.py
#   install diceware:
#      sudo pip install diceware
#    
# ---------------------------------------------------------------------------

# defaults
GROUP=sftpusers
BASE_DIR=/sftp/home
USER_DIR=/home
DRYRUN=

# ---------------------------------------------------------------------------
# generate a random password
# ---------------------------------------------------------------------------
randpw() {
   local pw

   if [ -z "`which diceware 2>/dev/null`" ]; then
      # fallback to using ugly random stuff
      pw=`strings < /dev/urandom | head -n40 | tr -dc '_@#%^&+:A-Za-z0-9' | fold -w12 | head -n1`
   else
      # nice, easily remembered password!
      #pw=`diceware -n5 -d'-' --no-caps`
      # this creates passwords that look better to clients
      pw=`diceware -n5 -s 4`
   fi

   echo $pw
}

# ---------------------------------------------------------------------------
# exit script with error message
# ---------------------------------------------------------------------------
die() {
   echo "$1"
   exit 1
}


USAGE="
Create an SFTP user on an ARC EC2 Amazon Linux box.
usage: `basename $0` [-h] [--dry-run]
with --dry-run it will echo the commands but not run them

"

if [ "$1" = "-h" ]; then
   die "$USAGE"
fi

if [ "$1" = "--dry-run" ]; then
   DRYRUN='echo'
fi

if [ `whoami` != 'root' ]; then
   die "You must be root to run this script"
fi

# verify arc group exists
user_group=`grep "^$GROUP:" /etc/group`
if [ -z "$user_group" ]; then
   die "No group named '$GROUP' exists, exiting..."
fi

# verify BASE_DIR exists
if [ ! -d "$BASE_DIR" ]; then
   die "Jailed sftp home dir '$BASE_DIR' does not exist, exiting..."
fi

echo "$USAGE"
echo
read -p "User's username: " user
echo
read -p "User's full name: " full_name
echo 
read -p "Do you want an auto-generated password? [Yn] " ans
if [ "$ans" = "" -o "$ans" = "Y" -o "$ans" = "y" -o "$ans" = "yes" ]; then
   password=$(randpw)
else
   read -p "Please enter users's password: " password
   echo
fi

# create a user WITHOUT it's home dir
comment="SFTP - $full_name"
$DRYRUN useradd -N -m -g $GROUP -b $BASE_DIR -s /sbin/nologin -c "$comment" $user || die "Error: on useradd $user"
$DRYRUN echo "$password" | passwd --stdin $user || die "Error: setting password for $user"

# modify user's home dir parameter so they are chdir'ed to a writeable dir
$DRYRUN usermod -d $USER_DIR/$user $user || die "Error: on usermod $user"

# create user's home dir with appropriate permissions
#$DRYRUN cd $BASE_DIR || die "Error: cd $BASE_DIR"
#$DRYRUN mkdir $user || die "Error: mkdir $user"
#$DRYRUN chown $user:$GROUP $user || die "Error: chown on $user dir"
#$DRYRUN chmod 755 $user || die "Error: chmod on $user"
#$DRYRUN cd $user || die "Error: cd $user"

echo 
echo "Please record the username/password!"
echo
echo "$user/$password"
echo


