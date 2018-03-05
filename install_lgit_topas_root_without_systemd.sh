#!/bin/sh

sysroot_tarball="root.tar.gz"
sysroot_folder="root"
remote_sysroot_installer_path="/data/lg_topas_root_complete"
systemd_remote_sysroot_installer_path="/data/lg_topas_root/root"
temp_sysroot_tarball_folder="/run/lg_topas_root"
output_file="/data/lg_script/installation_without_systemd.log"

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


create_usr_lib_links() {

cd $remote_sysroot_installer_path                                                                           
                                                                                
echo "<<<<Linking all the topas libraries and external libraries inside /usr/lib>>>>"
                                                                                     
for lib_file in $sysroot_folder/usr/lib/*                                            
do                                                                                               
    # to skip in existent files                                                  
    if [[ ! -e "$lib_file" ]]; then continue; fi                                 

    lib_name=$(basename "$lib_file")                                             
   
    # to skip existent files in the systemd rootfs 
    if [[ -e "${systemd_remote_sysroot_installer_path}/usr/lib/${lib_name}" ]]; then echo "${systemd_remote_sysroot_installer_path}/usr/lib/${lib_name} exists already [systemd rfs]" && continue; fi   
                                                
    # skip the pkgconfig folder                                                  
    if [[ "$lib_name" == "pkgconfig" ]]; then 
	echo "Skipping $lib_name"
        continue; 
    fi                       

    # skip the ssl folder                          
    if [[ "$lib_name" == "ssl" ]]; then                                                                                                                  
        echo "Skipping $lib_name folder"                                                                                                                              
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

    
    if echo "$lib_name" | grep -q "libblkid" ; then                                      
       echo "Skipping $lib_name"                                                           
       continue;                                                                           
    fi 

     if echo "$lib_name" | grep -q "libdbus-1" ; then                                      
       echo "Skipping $lib_name"                                                           
       continue;                                                                           
    fi


     if echo "$lib_name" | grep -q "libexpat" ; then                                      
       echo "Skipping $lib_name"                                                           
       continue;                                                                           
    fi


     if echo "$lib_name" | grep -q "liblzma" ; then                                      
       echo "Skipping $lib_name"                                                           
       continue;                                                                           
    fi


     if echo "$lib_name" | grep -q "libmount" ; then                                      
       echo "Skipping $lib_name"                                                           
       continue;                                                                           
    fi

	
     if echo "$lib_name" | grep -q "libnss_myhostname" ; then                                      
       echo "Skipping $lib_name"                                                           
       continue;                                                                           
    fi

     if echo "$lib_name" | grep -q "libuuid" ; then                                      
       echo "Skipping $lib_name"                                                           
       continue;                                                                           
    fi


    if [[ -h "/usr/lib/$lib_name" ]]; then                                                                
       echo "this symbolic link exists : /usr/lib/$(basename "$lib_file"). Replacing link."        
            rm /usr/lib/$lib_name
        elif [[ -e /usr/lib/$lib_name ]];then                                                                 
            echo "This lib/directory exists currently. Moving it to /usr/lib/${lib_name}_old"           
            mv /usr/lib/$lib_name /usr/lib/${lib_name}_old
            echo "Linking in the new library"                                                           
    fi                                                                                                  
                                                                                                            
    ln -svf $remote_sysroot_installer_path/$lib_file /usr/lib/$lib_name >> $output_file 2>&1

done   

}


create_usr_bin_links() {

echo "<<<<Linking all the topas binaries inside /usr/bin >>>>"                                              

cd $remote_sysroot_installer_path
                                                                                                           
for bin_file in $sysroot_folder/usr/bin/*                                                        
do                                                                                                  
        # to skip in existent files                                                                         
        if [[ ! -e "$bin_file" ]]; then continue; fi                                                        
                                                                                                            
        bin_name=$(basename "$bin_file")                                                            
            
        # to skip existent files in the systemd rootfs 
	if [[ -e "${systemd_remote_sysroot_installer_path}/usr/bin/${bin_name}" ]]; then echo "${systemd_remote_sysroot_installer_path}/usr/bin/${bin_name} exists already [systemd rfs]" && continue; fi
           

	if echo "$bin_name" | grep -q "dbus" ; then                                      
       		echo "Skipping $bin_name"                                                           
       		continue;                                                                           
    	fi        
           
       	if echo "$bin_name" | grep -q "components.xml" ; then                                      
       		echo "Skipping $bin_name"                                                           
       		continue;                                                                           
    	fi  
                                                                    
        if [ -h "/usr/bin/$bin_name" ]; then                                                                
                echo "this symbolic link exists : /usr/bin/$(basename "$bin_file"). Replacing link."        
                rm /usr/bin/$bin_name
        elif [ -e /usr/bin/$bin_name ];then                                                         
                echo "This bin/directory exists currently. Moving it to /usr/bin/${bin_name}_old"    
                mv /usr/bin/$bin_name /usr/bin/${bin_name}_old

                echo "Linking in the new binary"                                                            
        fi                                                                                                  
                                                                                                    
        ln -svf $remote_sysroot_installer_path/$bin_file /usr/bin/$bin_name >> $output_file 2>&1
done                     
}


create_lib_links() {

	echo "<<<<Linking all the topas binaries inside /lib >>>>"


	cd $remote_sysroot_installer_path
	for lib_file in $sysroot_folder/lib/*                                                                       
	do                                                                                                          
        
	# to skip in existent files                                                                         
        if [[ ! -e "$lib_file" ]]; then continue; fi                                                        
                                                                                                            
        lib_name=$(basename "$lib_file")                                                                    
              
	# to skip existent files in the systemd rootfs 
	if [[ -e "${systemd_remote_sysroot_installer_path}/lib/${lib_name}" ]]; then echo "${systemd_remote_sysroot_installer_path}/lib/${lib_name} exists already [systemd rfs]" && continue; fi
                                                                                              
    	# skip the pkgconfig folder                                                                             
    	if [[ "$lib_name" == "pkgconfig" || "$lib_name" == "modules" || "$lib_name" == "udev" || "$lib_name" == "systemd" ]]; then continue; fi
                                                                                                              
    	# skip the libstdc++, retain as on the LG board                                                           
    	if [[  "$lib_name" == "libcap.so"  || "$lib_name" == "libcap.so.2" || "$lib_name" == "libcap.so.2.24" ]]; then continue; fi

	
	if echo "$lib_name" | grep -q "libgcc_s" ; then                                                                                                                                            
             echo "Skipping $lib_name"                                                                                                                                                                 
             continue;                                                                                                                                                                                 
        fi  

	if echo "$lib_name" | grep -q "init" ; then                                                                              
                echo "Skipping $lib_name"                                                                                         
                continue;                                                                                                          
        fi     
                                                                                                              
   	if [ -h "/lib/$lib_name" ]; then                                                                          
                echo "this symbolic link exists : /lib/$(basename "$lib_file"). Replacing link."              
                rm /lib/$lib_name
    	elif [ -e /lib/$lib_name ];then                                                                           
        	echo "This lib/directory exists currently. Moving it to /lib/${lib_name}_old"                         
        	mv /lib/$lib_name /lib/${lib_name}_old
        	echo "Linking in the new library"                                                                     
    	fi                                                                                                        
                                                                                                              
      ln -svf $remote_sysroot_installer_path/$lib_file /lib/$lib_name >> $output_file 2>&1
done   


}

create_bin_links() {

echo "<<<<Linking all the topas binaries inside /bin >>>>"                                                    

cd $remote_sysroot_installer_path 
                                                                         
for bin_file in $sysroot_folder/bin/*                                                                         
do                                                                                                           
    # to skip in existent files                                                                               
    if [[ ! -e "$bin_file" ]]; then continue; fi                                                          
                                                                                                              
    bin_name=$(basename "$bin_file")   

    # to skip existent files in the systemd rootfs 
    if [[ -e "${systemd_remote_sysroot_installer_path}/bin/${bin_name}" ]]; then echo "${systemd_remote_sysroot_installer_path}/bin/${bin_name} exists already [systemd rfs]" && continue; fi
                                                                       

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
                echo "This bin/directory exists currently. Moving it to /bin/${bin_name}_old"                 
                mv /bin/$bin_name /bin/${bin_name}_old
                echo "Linking in the new binary"                                                              
        fi                                                                                                    

	                                                                                                              
    ln -svf $remote_sysroot_installer_path/$bin_file /bin/$bin_name >> $output_file 2>&1

done   

}

create_major_links () {

echo "Creating link for /etc/topas"
if [ -h /etc/topas ];then
    echo "Removing current symbolic link /etc/topas" 
    rm /etc/topas
fi

ln -sv $remote_sysroot_installer_path/root/etc/topas /etc/topas

#echo "Creating link for /usr/share/dbus-1 to ctp provided /usr/share/dbus-1 "
#if [ -h /usr/share/dbus-1 ];then
#    echo "Removing current symbolic link /usr/share/dbus-1"                                                                                             
#        rm /usr/share/dbus-1
#elif [ -d /usr/share/dbus-1 ];then
#    echo "Moving current /usr/share/dbus-1 to /usr/share/dbus-1_old"
#    mv /usr/share/dbus-1 /usr/share/dbus-1_old
#fi
#ln -s $remote_sysroot_installer_path/root/usr/share/dbus-1 /usr/share/dbus-1

echo "Creating link for /home/topas"
if [ -h /home/topas ];then
        echo "Removing current symbolic link /home/topas"                                                                 
        rm /home/topas
elif [ -d /home/topas ];then
        echo "Moving current /home/topas  to /home/topas_old"
        mv /home/topas /home/topas_old
fi

ln -sv $remote_sysroot_installer_path/root/home/topas /home/topas

#echo "Creating link for /tmp/topas"           
#if [ -h /tmp/topas ];then
#        echo "Removing current symbolic link /tmp/topas"                            
#        rm /tmp/topas

#elif [ -d /tmp/topas ];then
#        echo "Moving current /tmp/topas to /tmp/topas_old"
#        mv /tmp/topas /tmp/topas_old
#fi

#echo "ln -sv $remote_sysroot_installer_path/root/tmp/topas /tmp/topas  "

#echo "Creating link for /tmp/pinfo"
#if [ -h /tmp/pinfo ];then
#        echo "Removing current symbolic link /tmp/pinfo"                            
#        rm /tmp/pinfo
#elif [ -f /tmp/pinfo ];then
#        echo "Moving current /tmp/pinfo to /tmp/pinfo_old"
#        mv /tmp/pinfo /tmp/pinfo_old
#fi
#ln -sv $remote_env_installer_path/tmp/pinfo /tmp/pinfo

#echo "Creating link for /usr/bin/components.xml"
#if [ -h /usr/bin/components.xml ];then
#        echo "Removing current symbolic link /usr/bin/components.xml"            
#        rm /usr/bin/components.xml
#elif [ -f /usr/bin/components.xml ];then
#        echo "Moving current /usr/bin/components.xml to /usr/bin/components.xml"
#        mv /usr/bin/components.xml /usr/bin/components.xml_old
#fi
#ln -sv /data/lg_script/components.xml /usr/bin/components.xml

echo "Copying files for /usr/share/dbus-1"           
if [[ -e /usr/share/dbus-1 ]];then

        echo "Copy org.freedesktop.hostname1.conf|.service and org.freedesktop.systemd1.conf|.service"
	cp -a $remote_sysroot_installer_path/$sysroot_folder/usr/share/dbus-1/system.d/ /usr/share/dbus-1/
	cp $remote_sysroot_installer_path/$sysroot_folder/usr/share/dbus-1/system-services/* /usr/share/dbus-1/system-services/
	if [[ -e /usr/share/dbus-1/services ]];then 
		cp -a $remote_sysroot_installer_path/$sysroot_folder/usr/share/dbus-1/services/* /usr/share/dbus-1/services/
	else 
	   	cp -a $remote_sysroot_installer_path/$sysroot_folder/usr/share/dbus-1/services /usr/share/dbus-1/
	fi
        #mv /usr/share/dbus-1 /usr/share/dbus-1_old
fi

}


echo "*******************************************************************"                  
echo "**TOPAS  3 on board installation to LG board (no systemd changes)**"               
echo "*******************************************************************"                                   
                                                                                
untar_sysroot_tarball

if [[ -e $output_file ]];then                                                
            echo "This output file : ${output_file} exists currently. Moving it to ${output_file}_old"
            mv -f $output_file ${output_file}_old
fi

if [[ ! -e $systemd_remote_sysroot_installer_path ]]; then 
 exit 2
fi 

create_usr_lib_links 
create_usr_bin_links

create_lib_links
create_bin_links 

create_major_links 

exit 0
