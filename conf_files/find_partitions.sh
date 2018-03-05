#!/bin/sh
# Copyright (c) 2014, The Linux Foundation. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above
#       copyright notice, this list of conditions and the following
#       disclaimer in the documentation and/or other materials provided
#       with the distribution.
#     * Neither the name of The Linux Foundation nor the names of its
#       contributors may be used to endorse or promote products derived
#       from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT
# ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
# BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
# IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# find_partitions        init.d script to dynamically find partitions
#

UBI_ROOT=/usr/sbin

FindAndMountUBI () {
   partition=$1
   dir=$2

   mtd_block_number=`cat $mtd_file | grep -i $partition | sed 's/^mtd//' | awk -F ':' '{print $1}'`
   echo "MTD : Detected block device : $dir for $partition"
   mkdir -p $dir

   $UBI_ROOT/ubiattach -m $mtd_block_number -d 1 /dev/ubi_ctrl
   device=/dev/ubi1_0
   counter=0
   while [ ${counter} -le 100 ]
    do
        if [ -c $device ]
        then
            mount -t ubifs -o ro /dev/ubi1_0 $dir -o bulk_read
            break
        else
            sleep 0.010
        fi
	counter=$(( $counter + 1))
	if [ $counter == 100 ]
	then
	 echo "modem mount fail!" > /dev/kmsg
	 sys_reboot lgdload
	fi
    done
}
FindAndMount14UBI () {
   partition=$1
   dir0=$2
   dir1=$3

   echo "MTD : Detected block device : $dir for $partition" > /dev/kmsg
   
   nanddump -p -l 0x1 /dev/mtd14 -f /data/mtd14.txt
   ap_nand_val1=`cat /data/mtd14.txt | head -1 | awk '{print $2}'`
   ap_nand_val2=`cat /data/mtd14.txt | head -1 | awk '{print $3}'`
   
   mv /data/mtd14.txt /data/mtd14.old
   
   if [ $ap_nand_val1 -eq 55 -a $ap_nand_val2 -eq 42 ]
     then
		echo "MTD : cache partition is not empty" > /dev/kmsg
		empty_nand=10
     else
		echo "MTD : cache partition is empty" > /dev/kmsg
		empty_nand=11
   fi
   
   if [ $empty_nand -eq 10 ]
	then
		echo "MTD : Do not need format for cache" > /dev/kmsg
	else
		echo "MTD : Do format for cache" > /dev/kmsg
		$UBI_ROOT/ubiformat /dev/mtd14 -q -y -e 0
	fi
     
   $UBI_ROOT/ubiattach -m 14 -b 10 -d 2
   device0=/dev/ubi2_0
   device1=/dev/ubi2_1

# Mount directory check 
  if [ -d $dir0 ]
   then
    echo "MTD : $dir0 is exist" > /dev/kmsg
   else
    mkdir -p $dir0
  fi
	
  if [ -d $dir1 ]
   then
    echo "MTD : $dir1 is exist" > /dev/kmsg
   else
    mkdir -p $dir1
  fi
  
  if [ $empty_nand -eq 10 ]
    then
    counter=0
    while [ ${counter} -le 100 ]
      do
        if [ -c $device0 ] && [ -c $device1 ]
          then
          echo "MTD : No need to make volume" > /dev/kmsg
          break
        else
          sleep 0.010
        fi  
        counter=$(( $counter + 1))
        if [ $counter == 100 ]
          then
          echo "MTD : Make volume for cache. Node is not created" > /dev/kmsg
          $UBI_ROOT/ubimkvol /dev/ubi2 -s 14MiB -N cfg_volume
          $UBI_ROOT/ubimkvol /dev/ubi2 -m -N cache_volume
          break;
        fi  
    done
  else
    sleep 0.1
    echo "MTD : Make volume for cache" > /dev/kmsg
    $UBI_ROOT/ubimkvol /dev/ubi2 -s 14MiB -N cfg_volume
    $UBI_ROOT/ubimkvol /dev/ubi2 -m -N cache_volume
  fi

  counter=0
  while [ ${counter} -le 300 ]
    do
      if [ -c $device0 ]
        then
        echo "MTD : mount $dir0" > /dev/kmsg
        mount -t ubifs /dev/ubi2_0 $dir0 -o bulk_read
        break
      else
        sleep 0.010
      fi    
      counter=$(( $counter + 1))
      if [ $counter == 300 ]
        then
        echo "$dir0 mount fail!" > /dev/kmsg
      fi
  done
   
  counter=0
  while [ ${counter} -le 300 ]
   do
    if [ -c $device1 ]
      then
      echo "MTD : mount $dir1" > /dev/kmsg
      mount -t ubifs /dev/ubi2_1 $dir1 -o bulk_read
      break
    else
      sleep 0.010
    fi
		counter=$(( $counter + 1))
		if [ $counter == 300 ]
      then
      echo "cache mount fail!" > /dev/kmsg
    fi
  done
}

FindAndMountVolumeUBI () {
   volume_name=$1
   dir=$2
   if [ ! -d $dir ]
   then
       mkdir -p $dir
   fi
   mount -t ubifs ubi0:$volume_name $dir -o bulk_read
}

mtd_file=/proc/mtd

fstype="UBI"
eval FindAndMountVolume${fstype} usrfs /data
#dload mode setting
dload=`cat /data/dload_config | awk -F = '{print $2}'`
echo "dload = $dload "
echo "dload = $dload " > /dev/kmsg
echo "$dload" > /sys/module/msm_poweroff/parameters/download_mode
#eval FindAndMountVolume${fstype} cachefs /cache

eval FindAndMount${fstype} modem /firmware
eval FindAndMount14${fstype} cache /cfg /cache

exit 0
