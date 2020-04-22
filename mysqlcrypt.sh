#!/bin/bash

# start/stop mysql running in a LUKS encrypted container


cmount(){
   losetup /dev/loop0 /var/lib/mysql/mycrypt
   cryptsetup luksOpen /dev/loop0 mysqlcrypt
   mount /dev/mapper/mysqlcrypt /var/lib/mysql/mycryptmnt
}

cumount() {
   umount /var/lib/mysql/mycryptmnt
   cryptsetup luksClose /dev/mapper/mysqlcrypt
   losetup -d /dev/loop0
}

start(){
   cmount
   service mysqld start
}

stop(){
   service mysqld stop
   cumount
}

restart(){
    stop
    start
}


# See how we were called.
case "$1" in
  mount)
    cmount
    ;;
  umount)
    cumount
    ;;
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    restart
    ;;
#  status)
#    status -p "$mypidfile" $prog
#    ;;
  *)
    echo $"Usage: $0 {start|stop|restart}"
    exit 2
esac

