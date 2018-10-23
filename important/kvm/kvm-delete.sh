#!/bin/bash
[[ "$1" == "--help" || "$1"  == "-h"  || $# =  0 ]] && echo  "Usage:$(basename $0) domain" && exit
! virsh dominfo $1 &>/dev/null  && echo "Domain "$1" is not exist" && exit
virsh destroy $1 &>/dev/null
DELETE(){
	qcow2_dir=/var/lib/libvirt/images
	xml_dir=/etc/libvirt/qemu
	virsh undefine $1 &>/dev/null
	rm -rf $xml_dir/$1.xm*
	rm -rf $qcow2_dir/$1*.qcow2
	echo "Delete successfully!"
}
virsh list --all --without-snapshot |grep "^$1$" &>/dev/null && DELETE $1
virsh snapshot-list $1 &>/dev/null && read -p "Are you sure delete $1 ? (y/n): " choice
snapshot=$(virsh snapshot-list $1|awk '{print $1}')
if [ "$choice"  == "y" ];then
	for i in $qw2_dir/$snapshot;do
		virsh snapshot-delete $1 $i &>/dev/null
	done
	DELETE $1
fi
