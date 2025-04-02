#=============================================================================
# Copyright (c) 2023 Qualcomm Technologies, Inc.
# All Rights Reserved.
# Confidential and Proprietary - Qualcomm Technologies, Inc.
#=============================================================================

# Limit kswapd&kcompactd in cpu0-6
echo `ps -elf | grep -v grep | grep kswapd0 | awk '{print $2}'` > /dev/cpuset/kswapd-like/tasks
echo `ps -elf | grep -v grep | grep kcompactd0 | awk '{print $2}'` > /dev/cpuset/kswapd-like/tasks

configure_vm_parameters()
{
	MemTotalStr=`cat /proc/meminfo | grep MemTotal`
	MemTotal=${MemTotalStr:16:8}
	let RamSizeGB="( $MemTotal / 1048576 ) + 1"

	# Set the min_free_kbytes to standard kernel value
	if [ $RamSizeGB -ge 8 ]; then
		MinFreeKbytes=11584
	elif [ $RamSizeGB -ge 4 ]; then
		MinFreeKbytes=8192
	elif [ $RamSizeGB -ge 2 ]; then
		MinFreeKbytes=5792
	else
		MinFreeKbytes=4096
	fi

	# We store min_free_kbytes into a vendor property so that the PASR
	# HAL can read and set the value for it.
	echo $MinFreeKbytes > /proc/sys/vm/min_free_kbytes
	setprop vendor.memory.min_free_kbytes $MinFreeKbytes
}

configure_vm_parameters

# Run default post boot configuration
/vendor/bin/sh /vendor/bin/init.kernel.post_boot-cliffs_default_3_4_1.sh

