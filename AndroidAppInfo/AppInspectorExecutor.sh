#!/bin/sh

###
# @Author: FranzKafka
# @Date: 2024-11-11 09:21:03
# @LastEditTime: 2024-11-28 13:47:13
# @LastEditors: Franzkafka
# Description:a script for get App's info such as size,permissions,cpu,mem usages


#script version
TOOL_VERSION="1.0.1-2025.12.15"
#constants
APP_PACKAGE_NAME="com.seres.smartscene2"
#NOTE:defined in manifest,android.process
APP_PROCESS_NAME="com.seres.smartscene2"
APP_INSPECTOR_RESULT_DIR="/data/appinspector"
APP_INSPECTOR_RESULT_OUTPUT="result.txt"

#some info need to record
APP_APK_SIZE=""
APP_PACKAGE_LOCATION=""


function printVersion() {
    echo "current version:${TOOL_VERSION}" >> ${APP_INSPECTOR_RESULT_DIR}/${APP_INSPECTOR_RESULT_OUTPUT}
}

function printAppInfo() {
    echo "target package name:${APP_PACKAGE_NAME}" >> ${APP_INSPECTOR_RESULT_DIR}/${APP_INSPECTOR_RESULT_OUTPUT}
    echo "target process name:${APP_PROCESS_NAME}" >> ${APP_INSPECTOR_RESULT_DIR}/${APP_INSPECTOR_RESULT_OUTPUT}
}

function printBasicInfo() {
    printVersion
    printAppInfo
}

#如果之前存在执行中的进程，则需要kill掉
function clearSession() {
    local current_pid=$$
    # 获取所有与当前脚本相同的进程，排除当前进程
    local existing_pid=$(pgrep -f "AppInspectorExecutor.sh" | grep -v "^$" | grep -v "^$current_pid$")
    
    if [ -n "$existing_pid" ]; then
        echo "killing progress: $existing_pid"
        for pid in $existing_pid; do
            kill -9 $pid
        done
    fi
}

function disableSelinux() {
    setenforce 0
}

function createResultDir() {
    rm -rf ${APP_INSPECTOR_RESULT_DIR}
    #avoid \r\n when we use this in Windows env
    mkdir -p "$(echo "${APP_INSPECTOR_RESULT_DIR}" | tr -d '\r')"
}

function getAppLocation() {
    echo "---------------------------------------------" >> ${APP_INSPECTOR_RESULT_DIR}/${APP_INSPECTOR_RESULT_OUTPUT}
    APP_PACKAGE_LOCATION=$(pm list packages -a -f | grep -w ${APP_PACKAGE_NAME} | sed 's/package://' | awk -F "=${APP_PACKAGE_NAME}" '{print $1}')
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
    local pid=$(pidof ${APP_PROCESS_NAME})
    echo "---------------------------------------------" >> ${APP_INSPECTOR_RESULT_DIR}/${APP_INSPECTOR_RESULT_OUTPUT}
    echo "get cpu usage begin" >> ${APP_INSPECTOR_RESULT_DIR}/${APP_INSPECTOR_RESULT_OUTPUT}
    top -b -n 1 | grep -E "PID|${APP_PROCESS_NAME}" | grep -v "grep" >> ${APP_INSPECTOR_RESULT_DIR}/${APP_INSPECTOR_RESULT_OUTPUT}
    echo "get cpu usage end" >> ${APP_INSPECTOR_RESULT_DIR}/${APP_INSPECTOR_RESULT_OUTPUT}
    echo "---------------------------------------------" >> ${APP_INSPECTOR_RESULT_DIR}/${APP_INSPECTOR_RESULT_OUTPUT}
    echo "each thread usage begin" >> ${APP_INSPECTOR_RESULT_DIR}/${APP_INSPECTOR_RESULT_OUTPUT}
    top -b -H -p ${pid} -n 1 | sed 's/\x1b\[[0-9;]*m//g' >> ${APP_INSPECTOR_RESULT_DIR}/${APP_INSPECTOR_RESULT_OUTPUT}
    echo "each thread usage end" >> ${APP_INSPECTOR_RESULT_DIR}/${APP_INSPECTOR_RESULT_OUTPUT}
    echo "---------------------------------------------" >> ${APP_INSPECTOR_RESULT_DIR}/${APP_INSPECTOR_RESULT_OUTPUT}
}

function getAppGpuInfo() {
    gpu_data=$(dumpsys gfxinfo ${APP_PROCESS_NAME} | grep -A 1 "Total GPU memory usage:" | tail -n 1 | cut -d ',' -f2  | cut -d '(' -f1 | cut -d 'MB' -f 1)
    if [ -z "${gpu_data}" ]; then
        return
    fi
    gpu_data=$(echo "${gpu_data}" | sed 's/[^0-9.]//g')
    line="Total GPU memory usage:${gpu_data}"
    echo $line >> ${APP_INSPECTOR_RESULT_DIR}/${APP_INSPECTOR_RESULT_OUTPUT}
}

function main() {
    clearSession
    disableSelinux
    createResultDir
    printBasicInfo
    getAppLocation
    getAppAPKSize
    getAppPermissions
    while true
    do
        getAppMemoryInfo
        getAppCpuInfo
        getAppGpuInfo
        sleep 10
    done
}

main $*

