#/bin/bash
#this script is used for excute periodic check fot Vpses
#Author:FranzKafka
#Date:2021-09-05

echo "******This is a script for daily check for Vpses******"
timeStamp=$(date)
echo "Today is $timeStamp"
#topCmd=$(top -o %CPU |head -n 17)
echo "top cmd result is $topCmd"
message=$(netstat -plunt && top -o %MEM|head -n 10)
echo "This is information $message"
token=********************************************
id=**********
curl -s "https://api.telegram.org/bot${token}/sendMessage?chat_id=${id}" --data-binary "&text=${message}"
