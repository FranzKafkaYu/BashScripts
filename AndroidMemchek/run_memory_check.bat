rem This bat file is created by FranzKafka
rem Used for check memory info periodicly
rem If you have any question,you can visit https://coderfan.net
COLOR 4F
echo ========================��ȡrootȨ��=========================
                                        
adb wait-for-device
adb root
adb remount 
adb wait-for-device

echo ========================��������ļ�========================
adb shell setenforce 0
adb push showmap /system/bin/
adb push memory_check.sh /data/
adb shell chmod 777 /data/memory_check.sh

echo ========================ɾ����������========================
adb shell rm -rf /data/output

echo ========================ִ��Shel����========================
adb shell "sh -T- /data/memory_check.sh"
ping 127.0.0.1 -n 30 -w 1000 > NUL
adb shell ls -al /data/output
echo ========================��ʼִ������========================
PAUSE