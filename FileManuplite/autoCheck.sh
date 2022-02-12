#!/bin/bash
#This file will be used check whether these logs are too big
#If the files are bigger than 10M,then will automated deleted and restart X-UI
 Time=$(TZ=UTC-8 date)
 ErrorLogPath=/usr/local/x-ui/bin/error.log
 AccessLogPath=/usr/local/x-ui/bin/access.log
#检测文件是否存在

if [ ! -f "$AccessLogPath" ]; then
    echo "error:$AccessLogPath not exist"
    return 0
fi

if [ ! -f "$ErrorLogPath"]; then
    echo "error:$ErrorLogPath not exist"
    return 1
fi

#判断文件大小,使用“M”为计量单位,并取纯数字
ErrorLogdata=`ls -lah $AccessLogPath --block-size=M | awk '{print $5}'` | awk -F 'M' '{print $1}'
#或者使用stat -c %s  $AccessLogPath
echo "ErrorLogdata is $ErrorLogdata M"
AccessLogdata=`ls -lah $ErrorLogPath --block-size=M | awk '{print $5}'` | awk -F 'M' '{print $1}'
#或者使用stat -c %s  $AccessLogPath
echo "ErrorLogdata is $AccessLogdata M"

if [ $ErrorLogdata -gt 15 ];then
	rm  $ErrorLogPath
	systemctl restart x-ui
	echo "$ErrorLogPath is beyond 15M,remove it,date=$Time" >> rmError.log
else
	echo "$ErrorLogPath is $ErrorLogdataM,date=$Time" >> rmError.log 
fi

if [ $AccessLogdata -gt 15 ];then
	rm  $AccessLogPath
	systemctl restart x-ui
	echo "$AccessLogPath is beyond 15M,remove it" >> rmAccess.log
else
	echo "$AccessLogPath is $AccessLogdataM,date=$Time" >> rmAccess.log 
fi
 
 
 
