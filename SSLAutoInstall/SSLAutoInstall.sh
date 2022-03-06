#!/bin/bash
#This shell script is used for auto issue a Let'sEncrypt Cert And install it
#In this script,we will use Dns mode to issue a cert only
#what you need:
#              1.use cloudflare as your domain's nameserver and have add A records already
#              2.have necessary components such as curl,etc.
#Author:FranzKafka
#Date:2022-03-05
#Version:0.0.1

#some basic settings here
plain='\033[0m'
redColor='\033[0;31m'
greenColor='\033[0;32m'
yellowColor='\033[0;33m'

function LOGD() {
    echo -e "${yellowColor}[DEG] $* ${plain}"
}

function LOGE() {
    echo -e "${redColor}[ERR] $* ${plain}"
}

function LOGI() {
    echo -e "${greenColor}[INF] $* ${plain}"
}

#Check whether you are root
LOGD "**********************Root Check********************"
currentUser=$(whoami)
#more simple way:[[ $EUID -ne 0 ]],if true suggest you are root or you are not
#currentUser=$(whoami)
LOGD "currentUser is $currentUser"
if [ $currentUser != "root" ]; then
    LOGE "$Attention:请检查是否为root用户,please check whether you are root"
    exit 1
fi

currentPath=$(pwd)
LOGD "currentPath is $currentPath"
if [ currentPath != "/root" ]; then
    LOGD "Need change work directory to /root"
    cd /root
fi

LOGD "**********************Install Acme******************"
curl https://get.acme.sh | sh

#Check curl cmd whether succeed
if [ $? -ne 0 ]; then
    LOGE "Couldn't get acme shell script,please check your network here"
    exit 1
fi
#Cloudflare setup
LOGD "*********************Env   Setup*********************"
CF_GlobalKey=""
CF_AccountEmail=""
CF_Domain=""
LOGD "***********please setup your domain name*************"
read -p "Input your domain here:" CF_Domain
LOGD "Your domian name is -> ${CF_Domain} "
LOGD "*********please setup cloudflare golbal key**********"
read -p "Input your key here:" CF_GlobalKey
LOGD "Your Global Key is -> ${CF_GlobalKey}"
LOGD "*******please setup cloudflare account email*********"
read -p "Input your email here:" CF_AccountEmail
LOGD "Your Account Email is -> ${CF_AccountEmail}"
#Change acme default CA to cloudflare
LOGD "******************Change Default CA******************"
~/.acme.sh/acme.sh --set-default-ca --server letsencrypt
if [ $? -ne 0 ]; then
    LOGE "Change default CA failed"
    exit 1
fi
#Create /root/cert directory
certPath=/root/cert
if [ !-d $certPath ]; then
    mkdir $certPath
else
    rm -rf $certPath
    mkdir $certPath
fi
#Issue a cert,here is wildcard cert
export CF_Key="${CF_GlobalKey}"
export CF_Email=${CF_AccountEmail}
LOGD "Export CF_Key is $CF_Key "
LOGD "${yellowColor}Export CF_Email is $CF_Email "
~/.acme.sh/acme.sh --issue --dns dns_cf -d ${CF_Domain} -d *.${CF_Domain}

if [ $? -ne 0 ]; then
    LOGE "issue cert failed,please check your input"
    exit 1
fi
#Install your certs
~/.acme.sh/acme.sh --installcert -d ${CF_Domain} -d *.${CF_Domain} --ca-file /root/cert/ca.cer \
    --cert-file /root/cert/${CF_Domain}.cer --key-file /root/cert/${CF_Domain}.key \
    --fullchain-file /root/cert/fullchain.cer

if [ $? -ne 0 ]; then
    LOGE "${redColor}issue cert failed,please check acme output"
    exit 1
fi

#Setup auto upgrade
~/.acme.sh/acme.sh --upgrade --auto-upgrade

if [ $? -ne 0 ]; then
    LOGE "Setup Auto Upgrade failed,please check acme output here"
    exit 1
else
    LOGI "Your cert has been installed successfully,details as follows:"
    ls -lah cert
fi
