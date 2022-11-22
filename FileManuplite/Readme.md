1.该脚本是我在使用X-UI的过程中根据自己需求所写的，目的一是为了定时检测xray日志文件，当发现日志超过一定大小后即删除日志，二是隔一段时间更新geo数据，并重启X-UI  
2.该脚本将通过cron定时任务执行，在cron中添加定时任务如下：  
00 4 */2 * * /usr/local/x-ui/bin/autoCheck.sh >> /usr/local/x-ui/bin/autoCheck.log  

表明每隔两天执行该脚本进行检测  
