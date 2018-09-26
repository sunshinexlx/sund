#!/bin/bash
array=($1 $2 $3 $4 $5)
for x in {0..4};do

	for i in ${array[@]};do
	min=$1
		if [ $i -le $min ];then 
			min=$i
		else
			min=$i
		fi
	unset array[$x]
	go+="$min "
	done
done
echo $go

