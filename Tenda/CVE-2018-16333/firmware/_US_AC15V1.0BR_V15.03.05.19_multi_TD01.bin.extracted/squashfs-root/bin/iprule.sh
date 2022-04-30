#!/bin/sh

ACTION=$1
FILE=$2
TABLE=$3



if [ $# -ne 3 ];then
	echo "Parameter error"
	echo "Usage: $0 add|del file table"
	exit 1 
fi

rts=`cat $FILE`
if [ -z -rts ] ;then
	echo "cannot find file. "
	exit 1
fi

add_route_rule()
{
	if [ $TABLE = "ctc" ];then
	i=20000
	fi
	if [ $TABLE = "cnc" ];then
	i=22500
	fi
	if [ $TABLE = "cmc" ];then
	i=25000
	fi
	if [ $TABLE = "edu" ];then
	i=26000
	fi
 	for ip in $rts;do
		ip rule add to $ip table $1 pref $i
		i=`expr $i + 1`
 	done
}


del_route_rule()
{
	for ip in $rts;do
		ip rule del to $ip table $1	
	done
}

case $ACTION in
    add)
    add_route_rule $TABLE ;;
    del)
    del_route_rule $TABLE ;;
    *)
    echo "Usage: $0 add |del file table "
    exit 1 ;;
esac

