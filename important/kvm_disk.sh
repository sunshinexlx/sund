#!/bin/bash
#$1域名  $2大小
[ $# -eq 0 ]&>/dev/null||[ "$1" == "-h" ]&>/dev/null||[ "$1" == "--help" ]&>/dev/null&&echo "$0 -a domain size  |$0 -d domain disk-name "&&echo "如：$0 -a mini 2 |mini -d vdb"&&exit

[ -z  "$1" ] &>/dev/null ||[ -z  "$2" ] &>/dev/null ||[ -z  "$3" ] &>/dev/null&&echo "$0 -a domain size  |$0 -d domain disk-name "&&echo "如：$0 -a mini 2 |mini -d vdb"&&exit

function add(){ 	#$1是域名 $2是增加的大小 $where是即将要创建的disk[b-z]的磁盘文件  $who是即将增加的磁盘vd[b-z]
qcow2_dir=/kvm/disk
xml_dir=/etc/libvirt/qemu
cd $qcow2_dir
#查看目录下有没有disk1磁盘文件,依次往上加,没有即添加.
disk=({b..z})
i=0
while :;do
    where=${disk[$i]}
    cat $1_disk-vd$where.qcow2 &>/dev/null
    [ $? -ne 0 ]&&break
    let i++
done
qemu-img create -f qcow2 $1_disk-vd$where.qcow2 $2G

#查看域名中的磁盘,依次添加vdb-vdz.
j=0
while :;do
    who=${disk[$j]}
    virsh  domblkinfo $1 vd$who &>/dev/null
    [ $? -ne 0 ]&&break
    let j++
done
cat >>$1_disk.xml<<-eof 
<disk type='file' device='disk'>
   <driver name='qemu' type='qcow2'/> 
   <source file='$qcow2_dir/$1_disk-vd$where.qcow2'/> 
   <target dev='vd$who' bus='virtio'/>
</disk>
eof
virsh attach-device $1 $1_disk.xml --persistent
rm -rf $1_disk.xml
}
function delete(){
	qcow2_dir=/kvm/disk
	[ "$2" == "vda" ]&&echo "系统磁盘不允许删除!"&&exit
	virsh detach-disk $1 $qcow2_dir/$1_disk-$2.qcow2 --persistent
	rm -rf $qcow2_dir/$1_disk-$2.qcow2
}
case $1 in
    -a)
    add $2 $3;
        ;;
    -d)
    delete $2 $3;
        ;;
    *)
    echo "请输入正确选项!";
    exit;
        ;;
esac

