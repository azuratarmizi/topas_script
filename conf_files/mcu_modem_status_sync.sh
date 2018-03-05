#!/bin/sh

# Script to start sending MCU modem status through UART / MDX 
set -e

case "$1" in
  start)
        echo -n "[TOPAS3 mcu_modem_status_sync] Starting mcu_modem_status_sync: "

	start-stop-daemon -S -b -n mcu_modem_status_sync -a /usr/bin/mcu_modem_status_sync
	echo -n "done"

        ;;
  stop)
	echo -n "[TOPAS3 mcu_modem_status_sync] Stopping mcu_modem_status_sync: "            
        start-stop-daemon -K -n mcu_modem_status_sync
        echo "done"

        ;;
  restart)
        $0 stop
        $0 start
        ;;
  *)
        echo "Usage mcu_modem_status_sync.sh { start | stop | restart}" >&2
        exit 1
        ;;
esac

exit 0

