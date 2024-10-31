rem This bat file is created by FranzKafka
rem Used for check memory info periodicly
rem If you have any question,you can visit https://coderfan.net
COLOR 4F
echo ========================获取root权限=========================
                                        
adb wait-for-device
adb root
adb remount 
adb wait-for-device

echo ========================推入相关文件========================
adb shell setenforce 0
adb push showmap /system/bin/
adb push memory_check.sh /data/
adb shell chmod 777 /data/memory_check.sh

echo ========================删除旧有资料========================
adb shell rm -rf /data/output

echo ========================执行Shel任务========================
adb shell "sh -T- /data/memory_check.sh"
ping 127.0.0.1 -n 30 -w 1000 > NUL
adb shell ls -al /data/output
echo ========================开始执行任务========================
PAUSE