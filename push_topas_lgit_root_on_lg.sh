#!/bin/bash

## This script is to send the bsp/platform-ctp/root folder ( in a tarball ) to the LGIT board.
## NOTE : this script must be installed in : CTP_1XXX/topas_script directory and run from it. 
##        topas_script folder is at the same level as bsp folder

PLATFORM_TYPE="ctp"
TOPAS_ROOT_PATH="../bsp/platform-$PLATFORM_TYPE"

systemd_tarball="root_systemd.tar.gz"
sysroot_tarball="root.tar.gz"
remote_sysroot_installer_path="/run/lg_topas_root"
remote_lgit_script_installerpath="/data/lg_script"
#extract_script="install_lgit_topas_root.sh"
#copy_script="copy_systemd_files_to_lgit.sh"
lgit_ip="192.168.225.1"
install_systemd_script="install_lgit_systemd.sh"
install_topas_script="install_lgit_topas_root_without_systemd.sh"
#reinstall_topas_script="reinstall_lgit_topas_root_without_systemd.sh"
re_untar_topas_script="re_untar_lgit_topas_tarball.sh"

echo "*******************************************************"
echo "**Copy TOPAS 2 $PLATFORM_TYPE sysroot   to LG board       **"
echo "*******************************************************"

current_script_dir=${PWD}


print_help (){
    echo "   Usage : $0 <adb|scp>"
    echo "   NOTE : Please make sure this script location is in CTP_1XXX/topas_script. It must be run from inside \"topas_script\" folder !! "
    echo "          \"topas_script\" folder should be on the same level as \"bsp\" folder."
}


push_config_files (){

	cd ${current_script_dir}/conf_files
	echo "We are going to push all the conf files in this folder : ${PWD}"        
	adb push ./inittab /etc/inittab
	adb push ./syslog-startup.conf /etc/syslog-startup.conf
        adb push ./components.xml /usr/bin/components.xml
	adb push ./find_partitions.sh /etc/init.d/find_partitions.sh
	adb push ./sysfs.sh /etc/init.d/sysfs.sh
	adb push ./qmi_shutdown_modemd /etc/init.d/qmi_shutdown_modemd
        adb push ./network_config.xml /data/configs/network_config.xml
        adb push ./time_serviced /etc/init.d/time_serviced
	adb push ./start_fs-scrub-daemon /etc/init.d/start_fs-scrub-daemon
	adb push ./start_pdcd /etc/init.d/start_pdcd 
    	adb push ./start_embms_le /etc/init.d/start_embms_le
	adb push ./misc-daemon /etc/init.d/misc-daemon
    adb push ./mcu_modem_sync.sh /etc/init.d/mcu_modem_sync.sh

	#adb push ./target_setup_rc_script.sh /data/lg_script/target_setup_rc_script.sh
	#adb push ./install_lgit_systemd.sh /data/lg_script/install_lgit_systemd.sh

	if [ -e new_system.tar.gz ];then
    		mv new_system.tar.gz new_system.old.tar.gz
	fi
	tar czf ./new_system.tar.gz ./new_system
	echo "Pushing new_system.tar.gz " 
	adb push ./new_system.tar.gz /data/lg_script/new_system.tar.gz



	if [ -e etc.dbus-1.tar.gz ];then
	    mv etc.dbus-1.tar.gz etc.dbus-1.old.tar.gz
	fi
	tar czf ./etc.dbus-1.tar.gz ./dbus-1
	echo "Pushing etc.dbus-1.tar.gz" 
	adb push ./etc.dbus-1.tar.gz /data/lg_script/etc.dbus-1.tar.gz


}


if [[ $# -ne 1 ]];then
    print_help
    exit 1

elif [[ $1 != "adb" && $1 != "scp" ]];then 
        print_help
        exit 1

  else
    
	if [ -d "$TOPAS_ROOT_PATH/root" ];then 
		#Tar the root folder 
		echo "Creating ${TOPAS_ROOT_PATH}/${sysroot_tarball}."
		cd ${TOPAS_ROOT_PATH}
		tar czf $sysroot_tarball root
		echo " [${TOPAS_ROOT_PATH}/${sysroot_tarball}] is created"
		#Pushing topas libraries and executables on the LG board
		echo "pushing [${TOPAS_ROOT_PATH}/$sysroot_tarball] and [$current_script_dir/$systemd_tarball] folder tar ball to $remote_sysroot_installer_path"

		if [[ "$1" == "adb" ]]; then
		        adb push $current_script_dir/$systemd_tarball $remote_sysroot_installer_path/$systemd_tarball
		        adb push $sysroot_tarball $remote_sysroot_installer_path/$sysroot_tarball
		        adb push $current_script_dir/$install_topas_script $remote_lgit_script_installerpath/$install_topas_script
		        adb push $current_script_dir/$re_untar_topas_script $remote_lgit_script_installerpath/$re_untar_topas_script
			adb push $current_script_dir/$install_systemd_script $remote_lgit_script_installerpath/$install_systemd_script
                        adb push $current_script_dir/install.sh $remote_lgit_script_installerpath/install.sh
                        adb push $current_script_dir/reinstall.sh $remote_lgit_script_installerpath/reinstall.sh
		elif [[ "$1" == "scp" ]];then 
		        scp  $sysroot_tarball root@${lgit_ip}:$remote_sysroot_installer_path/$sysroot_tarball
			scp  $current_script_dir/$systemd_tarball root@${lgit_ip}:$remote_sysroot_installer_path/$systemd_tarball
		        scp $current_script_dir/$install_topas_script  root@${lgit_ip}:$remote_lgit_script_installerpath/$install_topas_script
		        scp $current_script_dir/$re_untar_topas_script  root@${lgit_ip}:$remote_lgit_script_installerpath/$re_untar_topas_script
			scp $current_script_dir/$install_systemd_script  root@${lgit_ip}:$remote_lgit_script_installerpath/$install_systemd_script
                        scp $current_script_dir/install.sh root@{lgit_ip}:$remote_lgit_script_installerpath/install.sh
			scp $current_script_dir/reinstall.sh root@{lgit_ip}:$remote_lgit_script_installerpath/reinstall.sh
		fi
            
    else 
		   echo "This $TOPAS_ROOT_PATH/root directory is not valid. Please recheck !!"
		   print_help 
    fi 


        if [[ "$1" == "adb" ]]; then
          echo "Pushing configuration files using adb"
          push_config_files 
        else
          echo "Pushing configuration files using $1 is not supported" 
        fi 

fi

exit $?
