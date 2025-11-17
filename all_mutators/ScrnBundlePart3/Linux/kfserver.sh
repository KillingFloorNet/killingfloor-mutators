#!/bin/sh
#clear

# Product:         KFServer startup script for Linux
# Author:          PooSH, contact via Steam: [ScrN]PooSH
# Original author: Terrorkarotte, contact: ulblock@gmx.de
# Thanks to:       Sascha Greuel, Sekra
#
# Usage:           update-rc.d kfserver.sh defaults
#
# Edit and uncomment it to your needs


# (!) DON'T FORGET TO CHANGE THE PATHS TO YOUR NEEDS!

############################# PATHS AND SYSTEM INFO ###########################
#Path to Killing Floor system directory
DIR=/opt/kfserver/system
# you need to create the folder log first!
# If you do not no log will be written !
LOG=$DIR/logs
DAEMON=$DIR/ucc-bin
LOGFILE=$LOG/kfdaemon.log

TITLE='KFServer Daemon'
NAME="kfserver"
DESC="Killing Floor"
INI="KillingFloor.ini"

RUN_AS_SERVICE=1 # set it to 1, if you will start kfserver as a service

if [ $RUN_AS_SERVICE -eq 0 ]
then
  # ucc-bin owner is taken
  USER=`ls -l ${DAEMON} | awk '{ print $3 }'`
  GROUP=`ls -l ${DAEMON} | awk '{ print $4 }'`
  # You probably can't write into /var/run/ unless you aren't root
  PIDFILE=/tmp/kfserver.pid
  # Time To Launch (seconds). Time, that is enough for server to launch completely
  # or exit, if there is an error in params.
  TTL=5
else
  # service should be running as root
  USER='root'
  GROUP='root'
  PIDFILE=/var/run/kfserver.pid
  TTL=0
fi

############################# GAME INFO #######################################
MAX_PLAYERS=6 # max player count
MAP=KF-Offices # default map to load
#default mutators, which server will always use, including "?Mutator=" string
MUTATORS=
#Add here additional mutators, which you want to run with ServerPerks (including)
SP_MUTATORS="ScrnSP.ServerPerksMutSE,ScrnBalanceSrv.ScrnBalance"


# No need to change function below! Modify SP_MUTATORS instead
SP_USED=0
fUseSP()
{
  if [ $SP_USED -eq 0 ]
  then
	  if [ -z ${MUTATORS} ]
	  then
	    MUTATORS="?Mutator=${SP_MUTATORS}"
	  else
	    MUTATORS="${MUTATORS},${SP_MUTATORS}"
	  fi
	  SP_USED=1
  fi

}

############################# SWITCHES ########################################
USE_SCREEN=0
KILL_ALL=0
fUseSP
VALID_SWITCHES=":c:dikm:rs"
while getopts $VALID_SWITCHES opt; do
  #echo "Option #${OPTIND}: $opt"
  case $opt in
    c)
      MAX_PLAYERS=$OPTARG
      ;;
    d)
      fUseSP
      MUTATORS="${MUTATORS},ScrnDoom3KF.Doom3Mutator"
      ;;
    i)
      INI=$OPTARG
      ;;
    k)
      KILL_ALL=1
      ;;
    m)
      MAP=$OPTARG
      ;;
    r)
      USE_SCREEN=1
      ;;
    s)
      fUseSP
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done






###############################################################################
############################# NO NEED TO EDIT UNDER HERE ######################
###############################################################################

PARAMS="server ${MAP}.rom?game=ScrnBalanceSrv.ScrnGameType?VACSecured=true?MaxPlayers=${MAX_PLAYERS}${MUTATORS} -nohomedir ini=${INI} log=$LOG/kfserver.log"

#echo "Mutators: "$MUTATORS
#echo "Params: "$PARAMS

#shows info on the screen and writes it in the log file
fEchoLog()
{
  echo $*
  echo $(date +"%Y-%b-%d %H:%M:%S")": $*" >> $LOGFILE
}

fCreatePID()
{
  ps ax | grep -v grep | grep $(basename $DAEMON) | grep -v export | awk '{print $1}' > $PIDFILE
  chown $USER:$GROUP $PIDFILE
  fEchoLog "$TITLE process ID has written to $PIDFILE."
}

fIsSrvRunning()
{
  SRV_RUNNING=$(ps ax | grep $(basename $DAEMON) | grep -v export | grep -v grep | wc -l)
}

fStartKF()
{
  # check if daemon exists
  if [ ! -x $DAEMON ]
  then
    fEchoLog "Can't find $DAEMON"
    exit 2
  fi

  # check if screen exists
  if [ $USE_SCREEN -eq 1 ] && [ ! -x `which screen` ]
  then
    fEchoLog "Can't find screen. Starting a server without it."
    USE_SCREEN=0
  fi

  fEchoLog "Params: $PARAMS"
  echo
  fEchoLog "Starting $DESC: $NAME..."

  cd $DIR
  if [ $USE_SCREEN -eq 1 ]
  then
    screen -d -m -S $NAME $DAEMON $PARAMS && sleep $TTL
    if [[ `screen -ls |grep $NAME` ]]
    then
      SRV_RUNNING=1
      fEchoLog 'Service started in screen mode'
      echo '(i) Type "screen -r" to view the server output'
      echo '(i) Then press "Ctrl+A D" to return to the shell'
    else
      fEchoLog 'ERROR!'
      exit 1
    fi
  else
    $DAEMON $PARAMS >> $LOGFILE 2>&1 &
    sleep $TTL
    # check if service running
    fIsSrvRunning
    if [ $SRV_RUNNING -eq 0 ]
    then
      fEchoLog 'Unable to start service!'
      exit 1
    else
      fEchoLog 'Service started'
    fi
  fi
}


fServiceStart() {
  #check if service is running
  fIsSrvRunning

  # Server not running and no pid-file found
  if [ $SRV_RUNNING -eq 0 ]
  then
    if [ -f $PIDFILE ]
    then
      fEchoLog "Server not running but pid-file present."
      rm $PIDFILE
      fEchoLog "Old pid file removed."
    fi
    fStartKF
    fCreatePID
  else
    if [ -f $PIDFILE ]
    then
      # Server running and pid-file found
      fEchoLog "$TITLE is already running."
    else
      # Server is running, but no pid file-found, so create a new one
      fEchoLog "Server is running but no pid file. Creating a new pid file..."
      fCreatePID
    fi
  fi

}


fServiceStop() {
  #check if service is running
  fIsSrvRunning

  if [ $SRV_RUNNING -eq 0 ]
  then
    # Server is not running
    if [ -f $PIDFILE ]
    then
      fEchoLog "$TITLE is not running, but pid-file is present."
      rm $PIDFILE
      fEchoLog "Pid-file removed."
    else
      fEchoLog "$TITLE is not running."
    fi
  else
    # Server is running
    if [ ! -f $PIDFILE ]
    then
        fEchoLog "$TITLE is running but no pid file found."
        fCreatePID
    fi

    fEchoLog "Stopping $TITLE..."
    kill $(cat $PIDFILE) >> $LOGFILE 2>&1
    rm -f $PIDFILE
    fEchoLog "$TITLE stopped."

    if [ $KILL_ALL -eq 1 ]
    then
      fEchoLog "-k switch found, killing all $(basename $DAEMON) instances..."
      killall -v $(basename $DAEMON) >> $LOGFILE 2>&1
    fi
  fi
}

fServiceStatus()
{
  fIsSrvRunning
  if [ $SRV_RUNNING -ge 1 ]
  then
    echo -e "$TITLE is [ \e[1;32mRUNNING\e[00m ]"
    if [ -f $PIDFILE ]
    then
      echo "PID = $(cat $PIDFILE)"
    else
      echo "PID file $PIDFILE not found"
      echo "List of running KF services:"
      ps ax | grep $(basename $DAEMON) | grep -v export | grep -v grep
    fi
  else
    echo -e "$TITLE is [ \e[1;31mNOT RUNNING\e[00m ]"
    exit 1
  fi
}


#last argument indicates command
ARGUMENTS=${@:1:`expr $# - 1`}
COMMAND=${@:$#:1}
#echo "Arguments $ARGUMENTS"
#echo "Command: $COMMAND"

case $COMMAND in
 start)
   fServiceStart
   ;;

 stop)
   fServiceStop
   ;;

 restart)
   fServiceStop
   sleep 1
   fServiceStart
   ;;

 status)
   fServiceStatus
   ;;

 help)
   echo Controls Killing Floor server
   echo "Usage: $(basename $0) [OPTIONS] {start|stop|restart|status|help}"
   echo '
SWITCHES:
start/restart commands:
  -c {PLAYER_COUNT}            Change player count (default=6)
  -d                           Use Doom3 monsters mutator
  -i {KILLINGFLOOR_INI}        Ini file to use, default is KillingFloor.ini
  -m {MAP_NAME}                Set the map. Specify map without extention, e.g.
                                 -m KF-Offices
  -r                           Run server in deatached screen mode. After launch
                                Type "screen -r" to see the server output
  -s                           Use ServerPerks mutators.
                                -s is used by default, if -d or -z specified.

stop commands:
  -k                           Kill all ucc-bin instances, even those which
                                did not started by this daemon.

Example:
  kfserver -d -c 6 -m KF-Offices start
'
   ;;

 *)
   echo "Usage: $(basename $0) [OPTIONS] {start|stop|restart|status|help}"
   exit 3
   ;;
esac

exit 0

