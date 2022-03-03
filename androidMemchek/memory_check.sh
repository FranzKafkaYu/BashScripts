#!/bin/sh

#This file will be used for shell excute memory check periodic
#Authored By FranzKafka

#Close Selinux 
setenforce 0
path=/data/output

#Path Check
if [ ! -d $path ];then
    echo "no output file,will create it"
	mkdir $path
else
    echo "output file exist,will remove it"
	rm -rf $path
    echo "now re-create it"
	mkdir $path
fi

#Get pid,there we used evsserver,you can replace it to the progeress name
evsserver_pid=`pidof evsserver`
echo "current pid $evsserver_pid ,we will begin check memory"
while true
do
	#Get time 
    Time=$(TZ=UTC-8 date)
    evsserver_pid=`pidof evsserver`
	#Get rss data
    rss_evsserver=$(cat /proc/${evsserver_pid}/status | grep -i vmrss | awk '{print $2}')
	#Vss unit tranformed to G
	rss_evsserver_unit_M=`expr $rss_evsserver / 1024 ` 
    echo "Current time $Time ,and the pid of evsserver is $evsserver_pid,RSS is $rss_evsserver KBytes($rss_evsserver_unit_M M)" >> /data/output/evsmemcheck.log
	
	
	#get all meminfo 
    date >> /data/output/dumpsys_meminfo.txt
	echo "dumpsys -t 30 begin"
    dumpsys -t 30 meminfo >> /data/output/dumpsys_meminfo.txt

	#get evsserver info
    date >> /data/output/dumpsys_meminfo_evsserver.txt
	echo "dumpsys evsserver begin"
    dumpsys meminfo -p ${evsserver_pid} >> /data/output/dumpsys_meminfo_evsserver.txt
	
	#get evsserver showmap info

    date >> /data/output/showmap_evsserver.txt
	echo "showmap evsserver begin"
    showmap ${evsserver_pid}  >> /data/output/showmap_evsserver.txt
	
	#get ion mm status

    date >> /data/output/ion_mm_heap.txt
	echo "cat ion_mm_heap begin"
    cat /sys/kernel/debug/ion/ion_mm_heap >> /data/output/ion_mm_heap.txt
	
	#get all proc meminfo

    date >> /data/output/proc_meminfo.txt
	echo "cat meminfo begin"
    cat /proc/meminfo >> /data/output/proc_meminfo.txt

	#get DMA info
    date >> /data/output/dma_buf.txt
    cat /d/dma_buf/bufinfo >> /data/output/dma_buf.txt

    date >> /data/output/dumpsys.txt
	echo "dumpsys begin"
    dumpsys > /data/output/dumpsys.txt
	
    #if rss is great than 1G,will generate tag file
    if [ $rss_evsserver -gt 1048576 ];then
        echo " $Time now evsserver(pid-> $evsserver_pid ) RSS beyond 1G,memory leak detected " >> /data/output/evsmemleakTag.txt
        exit
    fi
	#perioic time is 5s
    sleep 5

done
