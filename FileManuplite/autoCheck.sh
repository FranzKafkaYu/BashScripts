#!/bin/bash
#This file will be used check whether these logs are too big
#If the files are bigger than 10M,then will automated deleted and restart X-UI
#Attention:if this script need be excuted by cron,the file path mast be absolute.
Time=$(TZ=UTC-8 date)
ErrorLogPath=/usr/local/x-ui/bin/error.log
AccessLogPath=/usr/local/x-ui/bin/access.log
rmErrorLogPath=/usr/local/x-ui/bin/rmError.log
rmAccessLogPath=/usr/local/x-ui/bin/rmAccess.log
urlForGeoip='https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat'
urlForGeosite='https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat'

#更新geo数据
curl -s -L -o /usr/local/x-ui/bin/geoip.dat ${urlForGeoip}
if [[ $? -ne 0 ]]; then
	echo "update geoip.dat failed"
else
	echo "update geoip.dat succeed"
fi
curl -s -L -o /usr/local/x-ui/bin/geosite.dat ${urlForGeosite}
if [[ $? -ne 0 ]]; then
	echo "update geosite.dat failed"
else
	echo "update geosite.dat succeed"
fi

#检测文件是否存在
if [ ! -f "$AccessLogPath" ]; then
	echo "error:$AccessLogPath not exist"
fi

if [ ! -f "$ErrorLogPath" ]; then
	echo "error:$ErrorLogPath not exist"
fi

#判断文件大小,使用“M”为计量单位,并取纯数字
ErrorLogdata=$(ls -lah $ErrorLogPath --block-size=M | awk '{print $5}' | awk -F 'M' '{print$1}')
#或者使用stat -c %s  $AccessLogPath
echo "ErrorLogdata is $ErrorLogdata M,date=$Time"
AccessLogdata=$(ls -lah $AccessLogPath --block-size=M | awk '{print $5}' | awk -F 'M' '{print$1}')
#或者使用stat -c %s  $AccessLogPath
echo "AccessLogdata is $AccessLogdata M,date=$Time"

if [ $ErrorLogdata -gt 15 ]; then
	rm $ErrorLogPath
	echo "$ErrorLogPath is beyond 15M,remove it and restart X-ui,date=$Time" >>$rmErrorLogPath
else
	echo "$ErrorLogPath is $ErrorLogdata M,date=$Time" >>$rmErrorLogPath
fi

if [ $AccessLogdata -gt 15 ]; then
	rm $AccessLogPath
	echo "$AccessLogPath is beyond 15M,remove it and restart X-ui,date=$Time" >>$rmAccessLogPath
else
	echo "$AccessLogPath is $AccessLogdata M,date=$Time" >>$rmAccessLogPath
fi

systemctl restart x-ui
