#!/bin/bash
#database --> message,table --> info
#=======数据库客户端=======
rpm -q mariadb &>/dev/null
[ $? -ne 0 ] && yum install mariadb  -y
#===========数据库=======
rpm -q mariadb-server &>/dev/null
[ $? -ne 0 ] && yum install mariadb-server  -y && systemctl start mariadb
#=========服务是否启动===
netstat -tanp|grep mysqld &>/dev/null
[ $? -ne 0 ] && systemctl start mariadb
#======创建数据库及表===
mysql -e "show databases;" |grep message &>/dev/null
[ $? -ne 0  ] && mysql -e "create database message;" &>/dev/null
mysql -e "use message;show tables;" |grep info &>/dev/null
[ $? -ne 0  ] && mysql -e "create table message.info(username char(20),passwd varchar(41) not null,passwdagain varchar(20) not null,balance int unsigned default 100,primary key(username));"
SUPER(){
	case $
}
#============================开始界面部分=======================
START(){
	echo "		  #####################################"
	echo "		  #           1.注册                  #"
	echo "		  #           2.登录                  #"
	echo "		  #           3.退出                  #"
	echo "		  #####################################"
	read -p "请输入您要操作选项相应的数字:" menu
}
#============================主菜单部分=======================
MAIN(){
	echo "		  #####################################"
	echo "		  #           1.查询                  #"
	echo "		  #           2.充值                  #"
	echo "		  #           3.消费                  #"
	echo "		  #####################################"
	read -p "请输入您要操作选项相应的数字:" choice
}
BACK(){
	echo "		  #####################################"
	echo "		  #           1.返回主菜单            #"
	echo "		  #           2.退出                  #"
	echo "		  #####################################"
	read -p "请输入您要操作选项相应的数字:" back
	case $back in
	1)
		;;
	2)
		exit;;
	esac
}
	START
case $menu in
	1)
		read -p "请输入您要注册的用户名:" username
		while `mysql -e "select username from message.info;" |grep $username &>/dev/null`; [ $? -eq 0 ] ;do
		read -p  "您输入的用户已存在，请重新输入:" username
		done
		while [ $? -eq 0 ];do
		echo "请输入密码:" 
		read -s  passwd
		while [ -z $passwd ] ;do
		echo "输入密码不能为空，请重新输入："
		read -s  passwd
		done
		echo "请再次输入密码:"
		read -s passwdagain
		[ "$passwd" !=   "$passwdagain"  ] && echo "您两次输入的密码不一致!" 
		done
		mysql -e "insert into message.info set username='$username',passwd=password('$passwd'),passwdagain=password('$passwdagain');" &>/dev/null
		echo "注册成功" && sleep 1
	 	START ;;
esac
case $menu in
	2)
	i=1
	j=1
	read -p "请输入用户名:" username
	while `mysql -e "select username from message.info;"|grep $username &>/dev/null` ; [ $? -ne 0 ];do
		read -p "您输入的用户不存在，请重新输入：" username
	done
	echo "请输入密码:" 
	read -s  passwd
	while [ $i -le 3  ];do
		username=`mysql -e "select username from message.info where username='$username';" |awk 'NR>1{print $1}'`
		if `mysql -e "select count(*) from message.info where username='$username' and passwd=password('$passwd');" |grep 0 &>/dev/null`; [ $? -eq 0 ];then 
			echo "您输入的密码错误,请重新输入:"  && read -s passwd && let i++
		elif [ $j -eq 1 ];then
			MAIN
		case $choice in
			1)
				mysql -e "select * from message.info where username='$username';" |awk 'NR>1{print $4}' && sleep 1 && BACK ;;
			2)
				read -p "请输入充值金额：" money
				if [[ $money%50 -eq 0 ]];then
					have=`mysql -e "select * from message.info where username='$username';" |awk 'NR>1{print $4}'`
					mysql -e "update message.info set balance=$(($have+$money)) where username='$username';" 
				else
					echo "充值金额必须为50的整数倍。"
				fi && sleep 1 && BACK ;;
			3)
				read -p "请输入消费金额：" cost
				balance=`mysql -e "select * from message.info where username='$username';" |awk 'NR>1{print $4}'`
				if [ "$cost" -le $balance ];then
					 mysql -e "update message.info set balance=(($balance-$cost)) where username='$username';"
				else
					echo "消费金额不能超过余额。" 
				fi  && sleep 1 && BACK
		esac
		fi
	done ;;
esac
