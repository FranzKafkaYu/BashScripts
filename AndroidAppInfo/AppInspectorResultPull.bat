rem Autor:FranzKafkaYu
rem Date:2024/11/18

rem set up utf-8 encoding
chcp 65001

@echo off

echo ========================获取测试结果=========================
adb devices | find "device" > nul
if errorlevel 1 (
    echo "当前没有ADB设备,请检查ADB连接"
    exit 
)

adb pull /data/appinspector

pause