# ***************************************************************************
# $Id$
#
# Common BASH shell functions used throughout ARC code
#
# ***************************************************************************

# get the name of the calling script so we can use it in log messages
this=`basename $0`


# ---------------------------------------------------------------------------
_die() {
   msg="$1"   # optional error message you want printed
   rc=${2:-1} # optional return code to die with

   if [ -n "$msg" ]; then
       echo "$msg";
   fi
   exit $rc
}

# ---------------------------------------------------------------------------
_my_sigint() {
   echo "Ctrl-C pressed, aborting..."
   _cleanup
   exit 1
}
trap _my_sigint SIGINT

# ---------------------------------------------------------------------------
_say() {
   dt=`date | perl -ne 'chomp; print'`
   echo "$dt: $1"
}

# ---------------------------------------------------------------------------
# simple version, just accepts $?
# see below for more complex version
# ---------------------------------------------------------------------------
_chkerr_simple() {
   if [ $1 -ne 0 ]; then
      _say "$2 exited with error (rc=$1). You may want to check the logs"
      #_email "ERROR: $2"
      exit $1;
   fi
}
# ---------------------------------------------------------------------------
# check the return code for non zero status
# 
# Call like this after running a command:
#
#   my_script.sh
#   chkerr $? "something went wrong" my_script.sh
#
# Or like this after running a pipeline:
#
#   `foo | bar | baz`
#   chkerr "${PIPESTATUS[*]} $?"
# ---------------------------------------------------------------------------
#typeset -xf chkerr 
_chkerr() {
    rc_list="$1"      # return codes
    msg="$2"          # error message you want displayed if rc > 0
    script="$3"       # OPTIONAL name of the script or command who's return code we are checking
    
    # Process $rc in a loop, to support receiving an array of exit codes, for
    # pipelines (obtained from $PIPESTATUS in bash).  Note that they must be
    # passed as a single argument, typically by quoting.  In such a case, make
    # sure you're using bash, and use this syntax: chkerr "${PIPESTATUS[*]} $?"
    # The quotes, braces, and * are all required for it to work properly.
    # $PIPESTATUS is only set for pipelines, so the $? at the end there ensures
    # that if you convert a pipeline to a single command and don't convert the
    # chkerr line, the error will still be caught properly

    for rc in $rc_list; do
        if [ "$rc" -ne 0 ]; then
            _say "ERROR: $msg"
            echo -n "ERROR during $this: return code $rc"
            if [ -n "$script" ]; then echo -n " returned by $script"; fi
            #_email "ERROR: $2"
            _die
        fi
    done
}
#export chkerr


# ---------------------------------------------------------------------------
#
# The following should be copied and customized, not used directly
#
# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# you need to customize this
# ---------------------------------------------------------------------------
_cleanup() {
    _say "cleaning up..."
    cd $BASEDIR
    #rm -fr $tmpdir
}

# ---------------------------------------------------------------------------
# you need to customize this
# ---------------------------------------------------------------------------
_email() {
    msg="$1" # message you want to send

   _say "sending email"
   for e in $email_recipients; do
       #cat <<EOF | /usr/sbin/sendmail -f matt.jeffery@arkansas.gov matt.jeffery@arkansas.gov
       cat <<EOF | /usr/bin/mailx -t
From: matt.jeffery@arkansas.gov
To: $e
Subject: ERROR: some process

$1

EOF

done
}

# ---------------------------------------------------------------------------
# you need to customize this
# ---------------------------------------------------------------------------
_runsql() {
   sqlf=$1
   base=`basename $sqlf .sql`
   _say "running job: $sqlf";
   psql -X -a -U $dbuser -d $dbname -h $dbhost -f $sqlf > logs/$base.log
   _chkerr $? $sqlf
}

