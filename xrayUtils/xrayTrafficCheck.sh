#!/bin/bash

#This shell script will help you to check xray traffic by its given api
#And this script takes example by v2ray
#Author:FranzKafka
#Date:2022-03-019
#Version:0.0.1

#Here we set some basic args here

xrayApiServer=127.0.0.1:62789
xrayBinary=/usr/local/x-ui/bin/xray-linux-amd64

apidata() {
    local ARGS=
    if [[ $1 == "reset" ]]; then
        ARGS="reset: true"
    fi
    $xrayBinary api statsquery --server=$xrayApiServer "${ARGS}" |
        awk '{
        if (match($1, /"name":/)) {
            f=1; gsub(/^"|link"|,$/, "", $2);
            split($2, p,  ">>>");
            printf "%s:%s->%s\t", p[1],p[2],p[4];
        }
        else if (match($1, /"value":/) && f){ f = 0; printf "%.0f\n", $2; }
        else if (match($0, /}/) && f) { f = 0; print 0; }
    }'
}

print_sum() {
    local DATA="$1"
    local PREFIX="$2"
    local SORTED=$(echo "$DATA" | grep "^${PREFIX}" | sort -r)
    local SUM=$(echo "$SORTED" | awk '
        /->up/{us+=$2}
        /->down/{ds+=$2}
        END{
            printf "SUM->up:\t%.0f\nSUM->down:\t%.0f\nSUM->TOTAL:\t%.0f\n", us, ds, us+ds;
        }')
    echo -e "${SORTED}\n${SUM}" |
        numfmt --field=2 --suffix=B --to=iec |
        column -t
}

DATA=$(apidata $1)
echo "------------Inbound----------"
print_sum "$DATA" "inbound"
echo "-----------------------------"
echo "------------Outbound----------"
print_sum "$DATA" "outbound"
echo "-----------------------------"
echo
echo "-------------User------------"
print_sum "$DATA" "user"
echo "-----------------------------"
