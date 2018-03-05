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
reinstall_topas_script="reinstall_lgit_topas_root_without_systemd.sh"

echo "*******************************************************"
echo "**Copy TOPAS 2 $PLATFORM_TYPE sysroot   to LG board       **"
echo "*******************************************************"

current_script_dir=${PWD}


print_help (){
    echo "   Usage : $0 <adb|scp>"
    echo "   NOTE : Please make sure this script location is in CTP_1XXX/topas_script. It must be run from inside \"topas_script\" folder !! "
    echo "          \"topas_script\" folder should be on the same level as \"bsp\" folder."
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
		        adb push $sysroot_tarball $remote_sysroot_installer_path/$sysroot_tarball

		elif [[ "$1" == "scp" ]];then 
		        scp  $sysroot_tarball root@${lgit_ip}:$remote_sysroot_installer_path/$sysroot_tarball
		fi
            
	else 
		   echo "This $TOPAS_ROOT_PATH/root directory is not valid. Please recheck !!"
		   print_help 
        fi 

   fi 


exit $?
