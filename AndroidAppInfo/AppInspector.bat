rem Description:AppInspector,a tool for checking App details such runtime CPU,MEM info etc
rem Autor:FranzKafkaYu
rem Date:2024/10/30

rem set up encoding to utf-8

chcp 65001

@echo off
echo ========================获取root权限=========================
                                        
adb wait-for-device
adb root
adb remount 
adb wait-for-device

echo ========================推入相关文件========================
adb shell setenforce 0
adb push AppInspectorExecutor.sh /data/
adb shell chmod 777 /data/AppInspectorExecutor.sh

echo ========================删除旧有资料========================
adb shell rm -rf /data/appinspector

echo ========================执行Shel任务========================
adb shell "sh -T- /data/AppInspectorExecutor.sh"
ping 127.0.0.1 -n 30 -w 1000 > NUL
adb shell ls -al /data/appinspector
echo ========================结束执行任务========================
PAUSE