#!/bin/bash
#存储池路径
dir=/var/lib/libvirt/images/
cd $dir
#========添加 查看 恢复 删除==============
HELP(){
	echo "		-c,--create --> Example:$0 -c domain domain.snap"
	echo "		-l,--list   --> Example:$0 -l domain"
	echo "		-r,--revert --> Example:$0 -r domain domain.snap"
	echo "		-d,--create --> Example:$0 -d domain domain.snap"
}
CREATE(){
	virsh snapshot-create-as $domain $name
}
LIST(){
	virsh snapshot-list $domain
}
REVERT(){
	virsh snapshot-revert $domain $name
}
DELETE(){
	virsh snapshot-delete $domain $name
}
#=============使用======================
#========帮助信息============
[ "$1" == "-h" ] || [ "$1" == "--help" ] || [ $# -le 2 ]  &>/dev/null  && HELP && exit
#================快照操作===============
case  $1 in
-c)
	domain=$2
	name=$3
	CREATE ;;
-l)
	domain=$2
	LIST ;;
-r)
	domain=$2
	name=$3
	REVERT ;;
-d)
	domain=$2
	name=$3
	DELETE ;;
*)
	echo "请按操作要求使用，谢谢！" ;;
esac
