#!/bin/sh

#constants
APP_PACKAGE_NAME="com.example.smartscene"
#NOTE:APP_PROCESS_NAME normally same as APP_PACKAGE_NAME，but if it defined in manifest：android.process 
#the progress name will be changed
APP_PROCESS_NAME="com.example.smartscene"
APP_INSPECTOR_RESULT_DIR="/data/appinspector"
APP_INSPECTOR_RESULT_OUTPUT="result.txt"

#some info need to record
APP_APK_SIZE=""
APP_PACKAGE_LOCATION=""


function disableSelinux() {
    setenforce 0
}

function createResultDir() {
    rm -rf ${APP_INSPECTOR_RESULT_DIR}
    mkdir -p ${APP_INSPECTOR_RESULT_DIR}
}

function getAppLocation() {
    echo "---------------------------------------------" >> ${APP_INSPECTOR_RESULT_DIR}/${APP_INSPECTOR_RESULT_OUTPUT}
    APP_PACKAGE_LOCATION=$(pm path ${APP_PACKAGE_NAME} | cut -d ':' -f2)
    echo "name ${APP_PACKAGE_NAME} location:${APP_PACKAGE_LOCATION}" >> ${APP_INSPECTOR_RESULT_DIR}/${APP_INSPECTOR_RESULT_OUTPUT}
}

function getAppAPKSize() {
    echo "---------------------------------------------" >> ${APP_INSPECTOR_RESULT_DIR}/${APP_INSPECTOR_RESULT_OUTPUT}
    APP_APK_SIZE=$(du -h ${APP_PACKAGE_LOCATION} | cut -f1)
    echo "name ${APP_PACKAGE_NAME} size:${APP_APK_SIZE}" >> ${APP_INSPECTOR_RESULT_DIR}/${APP_INSPECTOR_RESULT_OUTPUT}
}

function getAppPermissions() {
    echo "---------------------------------------------" >> ${APP_INSPECTOR_RESULT_DIR}/${APP_INSPECTOR_RESULT_OUTPUT}
    dumpsys package ${APP_PACKAGE_NAME} | grep permission >> ${APP_INSPECTOR_RESULT_DIR}/${APP_INSPECTOR_RESULT_OUTPUT}
    echo "---------------------------------------------" >> ${APP_INSPECTOR_RESULT_DIR}/${APP_INSPECTOR_RESULT_OUTPUT}
}

#here we need check different type memory,such as PSS,RSS,USS
#PSS:Propotional Set Size
#USS:Unique Set Size
#RSS:Resident Set Size
function getAppMemoryInfo() {
    local pid=$(pidof ${APP_PROCESS_NAME})
    local Time=$(TZ=UTC-8 date)
    echo "---------------------------------------------" >> ${APP_INSPECTOR_RESULT_DIR}/${APP_INSPECTOR_RESULT_OUTPUT}
    echo "Time:${Time}" >> ${APP_INSPECTOR_RESULT_DIR}/${APP_INSPECTOR_RESULT_OUTPUT}
    echo "dumpsys procstats begin" >> ${APP_INSPECTOR_RESULT_DIR}/${APP_INSPECTOR_RESULT_OUTPUT}
    dumpsys procstats | grep -A 1 ${APP_PROCESS_NAME} >> ${APP_INSPECTOR_RESULT_DIR}/${APP_INSPECTOR_RESULT_OUTPUT}
    echo "dumpsys procstats end" >> ${APP_INSPECTOR_RESULT_DIR}/${APP_INSPECTOR_RESULT_OUTPUT}
    echo "---------------------------------------------" >> ${APP_INSPECTOR_RESULT_DIR}/${APP_INSPECTOR_RESULT_OUTPUT}
    echo "dumpsys meminfo begin" >> ${APP_INSPECTOR_RESULT_DIR}/${APP_INSPECTOR_RESULT_OUTPUT}
    dumpsys meminfo -p ${pid} >> ${APP_INSPECTOR_RESULT_DIR}/${APP_INSPECTOR_RESULT_OUTPUT}
    echo "dumpsys meminfo end" >> ${APP_INSPECTOR_RESULT_DIR}/${APP_INSPECTOR_RESULT_OUTPUT}
    echo "---------------------------------------------" >> ${APP_INSPECTOR_RESULT_DIR}/${APP_INSPECTOR_RESULT_OUTPUT}
    echo "shomap meminfo begin" >> ${APP_INSPECTOR_RESULT_DIR}/${APP_INSPECTOR_RESULT_OUTPUT}
    showmap ${pid} >> ${APP_INSPECTOR_RESULT_DIR}/${APP_INSPECTOR_RESULT_OUTPUT}
    echo "shomap meminfo end" >> ${APP_INSPECTOR_RESULT_DIR}/${APP_INSPECTOR_RESULT_OUTPUT}
    echo "\r\n"
}

function getAppCpuInfo() {
    echo "---------------------------------------------" >> ${APP_INSPECTOR_RESULT_DIR}/${APP_INSPECTOR_RESULT_OUTPUT}
    echo "dumpsys cpuinfo begin" >> ${APP_INSPECTOR_RESULT_DIR}/${APP_INSPECTOR_RESULT_OUTPUT}
    dumpsys cpuinfo | grep ${APP_PROCESS_NAME} >> ${APP_INSPECTOR_RESULT_DIR}/${APP_INSPECTOR_RESULT_OUTPUT}
    echo "dumpsys cpuinfo end" >> ${APP_INSPECTOR_RESULT_DIR}/${APP_INSPECTOR_RESULT_OUTPUT}
    echo "---------------------------------------------" >> ${APP_INSPECTOR_RESULT_DIR}/${APP_INSPECTOR_RESULT_OUTPUT}
}



function main() {
    disableSelinux
    createResultDir
    getAppLocation
    getAppAPKSize
    getAppPermissions
    while true
    do
        getAppMemoryInfo
        getAppCpuInfo
        sleep 5
    done

}

main $*

