#!/bin/bash
#========添加 查看 恢复 删除==============
HELP(){
    echo "      -a,--create --> Example:$0 -a domain domain.clone"
    echo "      -d,--delete --> Example:$0 -d domain"
}
[ $# -eq 0 ]&>/dev/null||[ "$1" == "-h" ]&>/dev/null||[ "$1" == "--help" ]&>/dev/null && HELP && exit

[ -z  "$1" ] &>/dev/null ||[ -z  "$2" ] &>/dev/null && HELP && exit
function add(){
virsh destroy $1 &>/dev/null
rom=$[$RANDOM%10]
rom2=$[$RANDOM%10]
echo $rom
echo $rom2
qcow2_dir=/var/lib/libvirt/images/
xml_dir=/etc/libvirt/qemu
#创建链接克隆
cd $qcow2_dir
qemu-img create -f qcow2 -b $1.qcow2 $2.qcow2
cp  $xml_dir/$1.xml $xml_dir/$2.xml
sed -i "/$1/s/$1/$2/g" $xml_dir/$2.xml
sed -r -i  "/uuid/s/(.*)(.)(.)(<)/\1$rom$rom2\4/" $xml_dir/$2.xml
#sed -ir "/uuid/s/>.*</>$uuid</g" $xml_dir/$2.xml
sed -r -i  "/mac address/s/(.*)(.)(.)(')/\1$rom$rom2\4/" $xml_dir/$2.xml
#sed -ir "/mac address/s/:?{2}'/$rom$rom2/" $xml_dir/$2.xml
virsh define $xml_dir/$2.xml
}
function delete(){
	qcow2_dir=/var/lib/libvirt/images/
	xml_dir=/etc/libvirt/qemu
	virsh destroy $1
	virsh undefine $1
	rm -rf $xml_dir/$1.xm*
	rm -rf $qcow2_dir/$1.qcow2
	echo "成功删除!"
}
case $1 in
	-a)
	add $2 $3;
		;;
	-d)
	delete $2;
		;;
	*)
	echo "请输入正确选项!";
	exit;
		;;
esac
