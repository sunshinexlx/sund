#!/usr/bin/bash
>ip.txt
#read -p "请输入IP地址和密码（如：172.16.119.1 root）" fip passwd
myip=`echo $1|sed -rn 's/(.*)(\..*$)/\1/p'`
rpm -q expect &>/dev/null
if [ $? -ne 0 ];then
	yum install -y expect
fi

if [ ! -f ~/.ssh/id_rsa  ];then
	ssh-keygen -P "" -f ~/.ssh/id_rsa
fi

for i in {2..245};do
	{
		ip=$myip.$i
		ping -c1 -W1 $ip &>/dev/null
		if [ $? -eq 0 ];then
			echo "$ip" >> ip.txt
			/usr/bin/expect <<-EOF
			set timeout 10
			spawn ssh-copy-id $ip
			expect {
					"yes/no" { send "yes\r"; exp_continue }
					"password:" { send "$2\r" }
			}
			expect eof
			EOF
		fi
	}&
	
done
