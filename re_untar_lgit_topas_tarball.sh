#!/bin/sh

sysroot_tarball="root.tar.gz"
sysroot_folder="root"
remote_sysroot_installer_path="/data/lg_topas_root_complete"
systemd_remote_sysroot_installer_path="/data/lg_topas_root/root"
temp_sysroot_tarball_folder="/run/lg_topas_root"
output_file="/data/lg_script/reinstallation.log"

untar_sysroot_tarball () {

	if [[ ! -e $temp_sysroot_tarball_folder/$sysroot_tarball ]];then 
		echo "$temp_sysroot_tarball_folder/$sysroot_tarball does not exist. Please provide it."
		exit 1
	fi

	if [[ ! -e $remote_sysroot_installer_path ]];then
		mkdir $remote_sysroot_installer_path 
	fi 
	echo "Untarring to : $remote_sysroot_installer_path/$sysroot_folder"
	cd $temp_sysroot_tarball_folder
	tar xzf ./$sysroot_tarball -C $remote_sysroot_installer_path
	#rm -rf $temp_sysroot_tarball_folder	
}

echo "*******************************************************************"                  
echo "**TOPAS  3 reinstallation on LG board (no systemd changes) ********"               
echo "*******************************************************************"                                   
                                                                                
untar_sysroot_tarball


exit 0
