#/bin/sh

sysroot_tarball="root_systemd.tar.gz"
sysroot_folder="root"
remote_sysroot_installer_path="/data/lg_topas_root"
temp_sysroot_tarball_folder="/run/lg_topas_root"
output_file="/data/lg_script/installation.log"

       

untar_sysroot_tarball () {

        echo "Untarring this tarball : $temp_sysroot_tarball_folder/$sysroot_tarball to $remote_sysroot_installer_path"
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


copy_usr_lib_links() {

cd $remote_sysroot_installer_path                                                                           
                                                                                
echo "<<<<Copying all the topas libraries and external libraries inside /usr/lib>>>>"
                                                                                     
for lib_file in $sysroot_folder/usr/lib/*                                            
do                                                                                               
    # to skip in existent files                                                  
    if [[ ! -e "$lib_file" ]]; then continue; fi                                 

    lib_name=$(basename "$lib_file")                                             
                                                      
    # skip the pkgconfig folder                                                  
    if [[ "$lib_name" == "pkgconfig" ]]; then 
	echo "Skipping $lib_name"
        continue; 
    fi                       
                                                                                     
    # skip the libstdc++, retain as on the LG board                              
    if [[  "$lib_name" == "libstdc++.so"  || "$lib_name" == "libstdc++.so.6"  || "$lib_name" == "libstdc++.so.6.0.20" || "$lib_name" == "libstdc++.la" ]]; then 
		echo "Skipping $lib_name"
		continue; 
    fi

    if echo "$lib_name" | grep -q "libffi" ; then 
		echo "Skipping $lib_name"
		continue; 
    fi 
        
    if echo "$lib_name" | grep -q "libgio" ; then                                          
        echo "Skipping $lib_name"                                             
        continue; 
    fi

    if echo "$lib_name" | grep -q "libglib" ; then                                          
        echo "Skipping $lib_name"                                                  
        continue;                                                                           
    fi 
          
    if echo "$lib_name" | grep -q "libgmodule" ; then                                         
       echo "Skipping $lib_name"                                                           
       continue;                                                                           
    fi 

    if echo "$lib_name" | grep -q "libgobject" ; then                                           
       echo "Skipping $lib_name"                                                           
       continue;                                                                           
    fi     

    if echo "$lib_name" | grep -q "libgthread" ; then                                           
       echo "Skipping $lib_name"                                                           
       continue;                                                                           
    fi    

    if echo "$lib_name" | grep -q "libnl" ; then                                      
       echo "Skipping $lib_name"                                                           
       continue;                                                                           
    fi 

    if [[ -h "/usr/lib/$lib_name" ]]; then                                                                
       echo "this symbolic link exists : /usr/lib/$(basename "$lib_file"). Replacing link."        
            rm /usr/lib/$lib_name                                                                
        elif [[ -e /usr/lib/$lib_name ]];then                                                                 
            echo "This lib/directory exists currently. Deleting /usr/lib/${lib_name}"           
            #mv /usr/lib/$lib_name /usr/lib/${lib_name}_old
            rm -f /usr/lib/$lib_name
            echo "Copying in the new library"                                                           
    fi                                                                                                  
    cp -a $remote_sysroot_installer_path/$lib_file /usr/lib/$lib_name >> $output_file 2>&1

done   

}


copy_usr_bin_links() {

echo "<<<<Copying all the topas binaries inside /usr/bin >>>>"                                              

cd $remote_sysroot_installer_path
                                                                                                           
for bin_file in $sysroot_folder/usr/bin/*                                                        
do                                                                                                  
        # to skip in existent files                                                                         
        if [[ ! -e "$bin_file" ]]; then continue; fi                                                        
                                                                                                            
        bin_name=$(basename "$bin_file")                                                            
                                                                                                            
        if [ -h "/usr/bin/$bin_name" ]; then                                                                
                echo "this symbolic link exists : /usr/bin/$(basename "$bin_file"). Replacing link."        
                rm /usr/bin/$bin_name
        elif [ -e /usr/bin/$bin_name ];then                                                         
                echo "This bin/directory exists currently. Deleting /usr/bin/${bin_name}"    
                #mv /usr/bin/$bin_name /usr/bin/${bin_name}_old                          
                rm  -f /usr/bin/$bin_name           
                echo "Copying in the new binary"                                                            
        fi                                                                                                  
         cp -a $remote_sysroot_installer_path/$bin_file /usr/bin/$bin_name >> $output_file 2>&1

done                     
}


copy_lib_links() {

	echo "<<<<Copying all the topas binaries inside /lib >>>>"


	cd $remote_sysroot_installer_path
	for lib_file in $sysroot_folder/lib/*                                                                       
	do                                                                                                          
        
	# to skip in existent files                                                                         
        if [[ ! -e "$lib_file" ]]; then continue; fi                                                        
                                                                                                            
        lib_name=$(basename "$lib_file")                                                                    
                                                                                                            
    	# skip the pkgconfig folder                                                                             
    	if [[ "$lib_name" == "pkgconfig" || "$lib_name" == "modules" || "$lib_name" == "udev" ]]; then continue; fi
                                                                                                              
    	# skip the libstdc++, retain as on the LG board                                                           
    	if [[  "$lib_name" == "libcap.so"  || "$lib_name" == "libcap.so.2" || "$lib_name" == "libcap.so.2.24" ]]; then continue; fi


	if echo "$lib_name" | grep -q "init" ; then                                                                              
                echo "Skipping $lib_name"                                                                                         
                continue;                                                                                                          
        fi     
                                                                                                              
   	if [ -h "/lib/$lib_name" ]; then                                                                          
                echo "this symbolic link exists : /lib/$(basename "$lib_file"). Replacing link."              
                rm /lib/$lib_name
    	elif [ -e /lib/$lib_name ];then                                                                           
        	echo "This lib/directory exists currently. Deleting /lib/${lib_name}"                         
        	#mv /lib/$lib_name /lib/${lib_name}_old                                                         
                rm -f /lib/$lib_name
        	echo "Copying in the new library"                                                                     
    	fi                                                                                                        
                                                                                                              
       cp -a $remote_sysroot_installer_path/$lib_file /lib/$lib_name >> $output_file 2>&1
done   


}

copy_bin_links() {

echo "<<<<Copying all the topas binaries inside /bin >>>>"                                                    

cd $remote_sysroot_installer_path 
                                                                         
for bin_file in $sysroot_folder/bin/*                                                                         
do                                                                                                           
    # to skip in existent files                                                                               
    if [[ ! -e "$bin_file" ]]; then continue; fi                                                          
                                                                                                              
    bin_name=$(basename "$bin_file")                                                                          

        if echo "$bin_name" | grep -q "mount" ; then                                              
                echo "Skipping $bin_name"                                                       
                continue;                                                                        
        fi   

        if echo "$bin_name" | grep -q "lsmod" ; then             
                echo "Skipping $bin_name"                                                       
                continue;               
        fi   
                                                                                                              
    if [ -h "/bin/$bin_name" ]; then                                                                          
                echo "this symbolic link exists : /bin/$(basename "$bin_file"). Replacing link."              
                rm /bin/$bin_name                                                                      
        elif [ -e /bin/$bin_name ];then                                                                       
                echo "This bin/directory exists currently. Deleting /bin/${bin_name}"                 
                #mv /bin/$bin_name /bin/${bin_name}_old
                rm /bin/$bin_name
                echo "Copying in the new bin binary"                                                              
        fi                                                                                                    

	                                                                                                              
    cp -a $remote_sysroot_installer_path/$bin_file /bin/$bin_name >> $output_file 2>&1
done   

}


copy_etc_files () {                                                                              
echo "<<<<copy all the folders/files inside /etc >>>>"                                       
                                                                                             
cd $remote_sysroot_installer_path                                                               
                                                                                                
for etc_file in $sysroot_folder/etc/*                                                           
do                                                                                              
    # to skip in existent files                                                                 
    if [[ ! -e "$etc_file" ]]; then continue; fi                                             
                                                                                                
    etc_name=$(basename "$etc_file")                                                         
                                                      
                                                                                             
    if [ -h "/etc/$etc_name" ]; then                                                    
                echo "this symbolic link exists : /etc/$(basename "$etc_file"). Replacing link."
                rm /etc/$etc_name                                                               
        elif [ -e /etc/$etc_name ];then                                                         
                echo "This bin/directory exists currently. Moving it to /etc/${etc_name}_old"   
                mv /etc/$etc_name /etc/${etc_name}_old                                          
                echo "Copy in the new etc file"                                                   
        fi                                                                                      
                                                                                                
                                                                                                
    cp -a $remote_sysroot_installer_path/$etc_file /etc/$etc_name >> $output_file 2>&1          
done                                                                                            
                                                                                                
}  

copy_service_files(){

   copy_etc_files
   #cp $remote_sysroot_installer_path/$sysroot_folder/etc/systemd/new_system.tar.gz /etc/systemd 
   cp /data/lg_script/new_system.tar.gz /etc/systemd 
   cd /etc/systemd

    if [[ -e /etc/systemd/new_system ]]; then 
       echo " /etc/systemd/new_system exist, moving it to new_system.old"
       mv /etc/systemd/new_system /etc/systemd/new_system.old
    fi 

    echo "Untarrring  new_system.tar.gz  at ${PWD}"
    tar xzf  new_system.tar.gz 
    mv system system_old
    mv new_system system 
#    cp -af new_system/* system

}




cleanup_dbus_service() {

rm -f /etc/rc3.d/*dbus*
rm -f /etc/rc5.d/*dbus*
rm -f /etc/init.d/dbus* 
ln -s /usr/lib/libyajl.so.2.1.0 /usr/lib/libyajl.so.2
}

install_etc_dbus_folder() {

cd /data/lg_script
tar xzf etc.dbus-1.tar.gz 
mv /etc/dbus-1 /etc/dbus-1.old
mv /data/lg_script/dbus-1 /etc
}


rc_script_setup(){

rm /etc/rc3.d/S15chgrp-diag
rm /etc/rc3.d/S20tftp_server.sh
rm /etc/rc3.d/S40thermal-engine
rm /etc/rc3.d/S45csdserver
rm /etc/rc3.d/S45qmi_shutdown_modemd
rm /etc/rc3.d/S55reset_reboot_cookie
rm /etc/rc3.d/S*start*
rm /etc/rc3.d/S99avahi-dnsconfd


cp -a /etc/rcS.d/* /etc/rc3.d              
mv /etc/rc3.d/S01networking /etc/rc3.d/S51networking              
mv /etc/rc3.d/S09sshd /etc/rc3.d/S59sshd              
mv /etc/rc3.d/S20hwclock.sh /etc/rc3.d/S70hwclock.sh              
mv /etc/rc3.d/S20syslog /etc/rc3.d/S70syslog              
mv /etc/rc3.d/S29init_irsc_util /etc/rc3.d/S79init_irsc_util              
mv /etc/rc3.d/S29time_serviced /etc/rc3.d/S79time_serviced                
mv /etc/rc3.d/S40qmuxd /etc/rc3.d/S90qmuxd                
mv /etc/rc3.d/S55bootmisc.sh /etc/rc3.d/S50bootmisc.sh                
rm /etc/rc3.d/S40start_qti_le
rm /etc/rc3.d/S38start_ipacmdiag_le
rm /etc/rc3.d/S37start_ipacm_perf_le
rm /etc/rc3.d/S37firmware-links.sh

rm /etc/rcS.d/*

ln -s /data/lg_topas_root/root/etc/machine-id /etc/machine-id

}

create_init_links() {

mv /sbin/init /sbin/init_old
mv /sbin/halt /sbin/halt_old
mv /sbin/poweroff /sbin/poweroff_old
mv /sbin/reboot /sbin/reboot_old

ln -svf /lib/systemd/systemd /sbin/init
ln -svf /bin/systemctl /sbin/halt
ln -svf /bin/systemctl /sbin/poweroff
ln -svf /bin/systemctl /sbin/reboot
}

echo "*******************************************************************"                  
echo "** etc and systemd on board installation to LG board       ********"               
echo "*******************************************************************"                                   
                                                                                
untar_sysroot_tarball

if [[ -e $output_file ]];then                                                
            echo "This output file : ${output_file} exists currently. Moving it to ${output_file}_old"
            mv -f $output_file ${output_file}_old
fi

copy_usr_lib_links 
copy_usr_bin_links

copy_lib_links
copy_bin_links 

copy_etc_files
copy_service_files
cleanup_dbus_service
install_etc_dbus_folder

##rc_script_setup

create_init_links

exit 0


