#!/bin/bash
#存储池路径
dir=/var/lib/libvirt/images/
cd $dir
#===============使用===================================
HELP(){
echo "		-a,--attach-device  -->Example: $0 -a host1 5G"
echo "		-d,--detach-disk    -->Example: $0 -d host1 dbc"
}
#=================================帮助信息====================
[ "$1" == "-h" ] || [ "$1" == "--help" ] || [ $# -eq 0 ]  &>/dev/null && HELP && exit
ADD(){
#`ls |grep $2 ; &>/dev/null ` [ $? -eq 0 ] && echo "磁盘文件名不能重复" && exit
devn=(vd{b..z})
i=0
for i in ${devn[@]} ; do
    virsh domblkinfo $domain $devn &>/dev/null ; [ $? -eq 0 ] &&  let i++ 
done
devn=${devn[$i]}
echo $devn
cat >> $dir$domain-$devn.xml<<eof
<disk type='file' device='disk'>
  <driver name='qemu' type='qcow2'/>
  <source file='/var/lib/libvirt/images/$domain-$devn.qcow2'/>
  <backingStore/>
  <target dev='$devn' bus='virtio'/>
  <alias name='virtio-disk0'/>
</disk>
eof
qemu-img create -f qcow2 $dir$domain-$devn.qcow2 $size
virsh attach-device $domain $dir$domain-$devn.xml --persistent
echo "您已经成功为$domain添加了$size的磁盘$devn"
}	
DELETE(){
	disk=$dir$domain-$devn.qcow2
	virsh detach-disk $domain $disk --persistent
	[ "$disk"  == "vda" ] && echo "您不能删除系统盘"
	rm -rf $dir$domain-$devn.xml
}
case $1 in
-a)
	domain=$2
	size=$3
	ADD ;;
-d)
	domain=$2
	devn=$3
	DELETE ;;
*)
	echo "您输入的参数无效"
esac
