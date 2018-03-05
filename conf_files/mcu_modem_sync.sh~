#!/bin/sh


set -e

case "$1" in
  start)
        echo -n "[TOPAS3_mcu_modem_sync] Checking the modem status is sysfs before syncing with MCU."
        search_dir="/sys/bus/msm_subsys/devices/"
        for entry in `ls $search_dir`
        do
            subsys_temp=`cat $search_dir/$entry/name`
            if [ "$subsys_temp" == "modem" ]
            then
                break
            fi
        done

	msstate=`cat $search_dir/$entry/state`

	if [ "$msstate" == "ONLINE" ]
	then
		   /usr/bin/send_mcu_channel_ready

		   if [ $? -neq 0 ]
		   then 
			echo -n "[TOPAS3_mcu_modem_sync] send_mcu_channel_ready failed. Exiting..."
			exit 1
		   else 

			# Starting the MCU heart beat apps
			echo -n "[TOPAS3_mcu_modem_sync] Starting send_mcu_heartbeat: "
	 		start-stop-daemon -S -b -a /usr/bin/send_mcu_heartbeat
	 		echo -n "done"
	
		   fi
	 else 
		echo -n "[TOPAS3_mcu_modem_sync] $search_dir/$entry/state = $msstate. Not ONLINE. Exiting..."
		exit 1
	 fi

        ;;
  stop)
	echo -n "Stopping send_mcu_heartbeat: "            
        start-stop-daemon -K -n /usr/bin/send_mcu_heartbeat
        echo "done"

        ;;
  restart)
        $0 stop
        $0 start
        ;;
  *)
        echo "Usage mcu_modem_sync.sh { start | stop | restart}" >&2
        exit 1
        ;;
esac

exit 0

