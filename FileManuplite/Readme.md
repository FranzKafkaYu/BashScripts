1.该脚本是我在使用X-UI的过程中根据自己需求所写的，目的是为了定时检测xray日志文件，当发现日志超过一定大小后即删除日志，并重启X-UI  
2.该脚本将通过cron定时任务执行，在cron中添加定时任务如下：
00 0 * * 0 /usr/local/x-ui/bin/autoCheck.sh >> /usr/local/x-ui/bin/autoCheck.log
