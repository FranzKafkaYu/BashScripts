#!/bin/bash
########################################################
#
#FILE          : ShellScriptUtils.sh
#
#DESCRIPTION   : Some basic utils function 
#
#VERSION       : 1.0.0
#DATE          : 2022-03-15
#AUTHOR        : FranzKafkaYu
#HISTORY       :
#
########################################################
# 获取脚本路径
cd "$(dirname "$BASH_SOURCE")"
script_file=$(pwd)/$(basename "$BASH_SOURCE")
script_path=$(dirname "$script_file")
cd - >/dev/null

echo "ShellUtils.sh's path is ${script_path}"

########################################################
# 日志打印参数及函数
########################################################
# 脚本日志等级定义
log_level_off=0
log_level_error=1
log_level_warn=2
log_level_info=3
log_level_verbose=4
log_level_all=5

# 默认日志等级
log_level=$log_level_all

# 函数功能：错误日志打印
# 参数1：日志内容
function LOGE() {
    if [ $log_level -ge $log_level_error ]; then
        echo -e "\033[1;31m$*\033[0m"
    fi
}

# 函数功能：警告日志打印
# 参数1：日志内容
function LOGW() {
    if [ $log_level -ge $log_level_warn ]; then
        echo -e "\033[1;33mWARN: $*\033[0m"
    fi
}

# 函数功能：通告日志打印
# 参数1：日志内容
function LOGI() {
    if [ $log_level -ge $log_level_info ]; then
        echo -e "\033[1;32mINFO: $*\033[0m"
    fi
}

# 函数功能：详细日志打印
# 参数1：日志内容
function LOGV() {
    if [ $log_level -ge $log_level_verbose ]; then
        echo -e "VERBOSE: $*"
    fi
}

# 函数功能：设置脚本日志等级
# 参数1：脚本日志等级(取值参考脚本日志等级定义)
# 返回值：设置成功返回0，设置失败返回1
function SetEvsScriptLogLevel() {
    if [ $# -ne 1 ]; then
        LOGE "Input parameter error! parameter number:$#, need 1 parameter"
        return 1
    fi
    if [ $1 -lt $log_level_off -o $1 -gt $log_level_all ]; then
        LOGE "Error evs script log level:$1!"
        return 1
    fi
    log_level=$1
    return 0
}

# 函数功能：日志打印
# 颜色：红色
# 参数1：日志内容
function LOG_RED() {
    echo -e "\033[1;31m$*\033[0m"
}

# 函数功能：日志打印
# 颜色：黄色
# 参数1：日志内容
function LOG_YELLOW() {
    echo -e "\033[1;33m$*\033[0m"
}

# 函数功能：日志打印
# 颜色：绿色
# 参数1：日志内容
function LOG_GREEN() {
    echo -e "\033[1;32m$*\033[0m"
}

# 函数功能：日志打印
# 颜色：蓝色
# 参数1：日志内容
function LOG_BLUE() {
    echo -e "\033[1;34m$*\033[0m"
}

# 函数功能：日志打印
# 颜色：紫色
# 参数1：日志内容
function LOG_PURPLE() {
    echo -e "\033[1;35m$*\033[0m"
}

# 函数功能：日志打印
# 颜色：天蓝色
# 参数1：日志内容
function LOG_CERULEAN() {
    echo -e "\033[1;36m$*\033[0m"
}

# 函数功能：日志打印
# 颜色：默认颜色色
# 参数1：日志内容
function LOG() {
    echo -e "$*"
}

########################################################
# 公共函数
########################################################
# 函数功能：判断元素是否在列表中
# 参数1：元素
# 参数2：列表
# 返回值：元素在列表中返回0，元素不在列表中返回1
function contains() {
    if [ $# -ne 2 ]; then
        LOGE "Input parameter error! parameter number:$#, need 2 parameter"
        return 1
    fi
    local list=$2
    LOGV "list size:${#list[*]}"
    LOGV "list:${list[*]}"
    for element in ${list[@]}; do
        if [ "$element" = "$1" ]; then
            LOGV "The list:(${list[*]}) contains this element:$1"
            return 0
        fi
    done
    LOGE "The list:(${list[*]}) does not contain this element:$1"
    return 1
}

