#!/bin/bash
#This script can send a alert when someone login into vps 
#date:2021-09-02
#name：SSHLoginAlert.sh
#author:FranzKafka

echo "This is a script for ssh login alert"
token=xxxxxxxxxxxxxxxxx
echo "my token is $token"
id=xxxxxx
echo "my id is $id"
message=$(hostname && TZ=UTC-8 date && who && w && last -1 | awk  'BEGIN{ORS="\t"}{print $1,$15}')
echo "send message is $message,begin...."
curl -v "https://api.telegram.org/bot${token}/sendMessage?chat_id=${id}" --data-binary "&text=${message}"
echo "send alert end"
