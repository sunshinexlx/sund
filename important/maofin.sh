#!/bin/bash
read -p "input 5 numbers: " one two three four five
array=($one  $two $three $four $five)
for j in {1..5};do
	for i in {0..3};do
		if [ ${array[$i]} -gt ${array[$i+1]} ];then
			tmp=${array[$i]}
			array[$i]=${array[$i+1]}
			array[$i+1]=$tmp
#		else
#			tmp=${array[$i]}
		fi
	done
done
	echo ${array[*]}	
