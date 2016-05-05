#!/bin/bash
# chkconfig: 235 99 10
# description: Start or stop the Uni System Daemon
#
### BEGIN INIT INFO
# Provides: uni-system-d
# Required-Start: $all
# Required-Stop: $network
# Default-Start: 2 3 5
# Default-Stop: 0 1 6
# Description: Start or stop the Uni System Daemon
### END INIT INFO

# Set account username that is running this. One per system !
r_user=seth

prog_path=/home/$r_user/unisystem
uni_host_name="$(hostname)"
#uni_host_name=""

name='uni-system-d'
start=$prog_path/uni-system-prog.sh
stop=$prog_path/uni-system-prog.sh
lockfile=$prog_path/init
confFile=$prog_path/init/uni-system-d.conf
pidFile=$prog_path/init/uni-system-d_$uni_host_name.pid
mkdir -p $prog_path/scripts/system/logs/$uni_host_name/
log_file=$prog_path/scripts/system/logs/$uni_host_name/uni-system-d.log
error_log_file=$prog_path/scripts/system/logs/$uni_host_name/uni-system-d.error_log
nice_priority=10

case "$1" in
'start')

	echo "Starting uni-system..."
	start-stop-daemon --background --pidfile $pidFile --make-pidfile --chdir $prog_path --nice $nice_priority --start --exec $start > $log_file 2>&1

		# Gentoo only ? --stdout $log_file --stderr $error_log_file

	#$start >/dev/null 2>&1 </dev/null
	#RETVAL=$?
	#if [ "$RETVAL" = "0" ]; then
	#	touch $lockfile >/dev/null 2>&1
	#fi
	;;
'stop')

	echo "Stopping uni-system..."
	start-stop-daemon --stop --pidfile "$pidFile"

	#$stop
	#RETVAL=$?
	#if [ "$RETVAL" = "0" ]; then
	#	rm -f $lockfile
	#fi
	#pidfile=`grep "^pidfile=" $confFile | sed -e 's/pidfile=//g'`
	#if [ "$pidfile" = "" ]; then
	#	pidfile=$pidFile
	#fi
	#rm -f $pidfile
	;;
'status')
	pidfile=`grep "^pidfile=" $confFile | sed -e 's/pidfile=//g'`
	if [ "$pidfile" = "" ]; then
		pidfile=$pidFile
	fi
	if [ -s $pidfile ]; then
		pid=`cat $pidfile`
		kill -0 $pid >/dev/null 2>&1
		if [ "$?" = "0" ]; then
			echo "$name (pid $pid) is running"
			RETVAL=0
		else
			echo "$name is stopped"
			RETVAL=1
		fi
	else
		echo "$name is stopped"
		RETVAL=1
	fi
	;;
'restart')
	echo "Restarting uni system ..."
	$0 stop
	sleep 2
	$0 start
	RETVAL=$?
	;;
'setup')

	;;
*)
	echo "Usage:	$0 { start | stop | restart }"
	echo "or	$0 { setup } to install in /etc/init.d as a boot script."
	RETVAL=1
	;;
esac
exit $RETVAL

