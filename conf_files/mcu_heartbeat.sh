#!/bin/sh

# Script to start sending mcu_heartbeat to MCU through UART
set -e

case "$1" in
  start)
        echo -n "[TOPAS3 mcu_heartbeat] Starting heartbeat: "

	start-stop-daemon -S -b -n mcu_heartbeat -a /usr/bin/mcu_heartbeat
	echo -n "done"

        ;;
  stop)
	echo -n "[TOPAS3 mcu_heartbeat] Stopping send_mcu_heartbeat: "            
        start-stop-daemon -K -n mcu_heartbeat
        echo "done"

        ;;
  restart)
        $0 stop
        $0 start
        ;;
  *)
        echo "Usage mcu_heartbeatc.sh { start | stop | restart}" >&2
        exit 1
        ;;
esac

exit 0

