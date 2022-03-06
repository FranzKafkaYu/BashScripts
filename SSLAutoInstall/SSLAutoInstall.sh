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

#Check whether you are root
echo "${yellowColor}**********************Root Check********************${plain}"
currentUser=$(whoami)
#more simple way:[[ $EUID -ne 0 ]],if true suggest you are root or you are not
#currentUser=$(whoami)
echo "currentUser is $currentUser"
if [ $currentUser != "root" ]; then
    echo -e "${redColor}Attention:请检查是否为root用户,please check whether you are root ${plain}\n"
    exit 1
fi

currentPath=$(pwd)
echo "currentPath is $currentPath"
if [ currentPath != "/root" ]; then
    echo "Need change work directory to /root"
    cd /root
fi

echo "${yellowColor}**********************Install Acme******************${plain}"
curl https://get.acme.sh | sh

#Check curl cmd whether succeed
if [ $? -ne 0 ]; then
    echo -e "${redColor}Couldn't get acme shell script,please check your network here${plain}"
    exit 1
fi
#Cloudflare setup
echo "${yellowColor}*********************Env   Setup*********************${plain}"
CF_GlobalKey=""
CF_AccountEmail=""
CF_Domain=""
echo "${yellowColor}***********please setup your domain name*************${plain}"
read -p "Input you domain here:" CF_Domain
echo "${yellowColor}Your domian name is -> ${CF_Domain} ${plain}"
echo "${yellowColor}*********please setup cloudflare golbal key**********${plain}"
read -p "Input you key here:" CF_GlobalKey
echo "${yellowColor}Your Global Key is -> ${CF_GlobalKey} ${plain}"
echo "${yellowColor}*******please setup cloudflare account email*********${plain}"
read -p "Input you email here:" CF_AccountEmail
echo "Your Account Email is -> ${CF_AccountEmail}"
#Change acme default CA to cloudflare
echo "${yellowColor}******************Change Default CA******************${plain}"
~/.acme.sh/acme.sh --set-default-ca --server letsencrypt
if [ $? -ne 0 ]; then
    echo -e "${redColor}Change default CA failed${plain}"
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
echo "${yellowColor}Export CF_Key is $CF_Key ${plain}"
echo "${yellowColor}Export CF_Email is $CF_Email ${plain}"
~/.acme.sh/acme.sh --issue --dns dns_cf -d ${CF_Domain} -d *.${CF_Domain}

if [ $? -ne 0 ]; then
    echo -e "${redColor}issue cert failed,please check your input${plain}"
    exit 1
fi
#Install your certs
~/.acme.sh/acme.sh --installcert -d ${CF_Domain} -d *.${CF_Domain} --ca-file /root/cert/ca.cer \
    --cert-file /root/cert/${CF_Domain}.cer --key-file /root/cert/${CF_Domain}.key \
    --fullchain-file /root/cert/fullchain.cer

if [ $? -ne 0 ]; then
    echo -e "${redColor}issue cert failed,please check acme output${plain}"
    exit 1
fi

#Setup auto upgrade
~/.acme.sh/acme.sh --upgrade --auto-upgrade

if [ $? -ne 0 ]; then
    echo "${redColor}Setup Auto Upgrade failed,please check acme output here${plain}"
    exit 1
else
    echo "${greenColor}Your cert has been installed successfully,details as follows:"
    ls -lah cert
    echo "${plain}"
fi
