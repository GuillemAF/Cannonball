#!/bin/bash


if [ $1 == "-h" ] || [ $1 == "--help" ]
then
	echo -e "Cannonball is used to gather open source intelligence (OSINT) on a domain. All the information that this script gathers, will be downloaded for a later documentation.\n\n Options: \n\n-d	Input domain.\n-f	Input the name of the folder.\n-c	Extract headers with curl\n-w	Webfuzzing with wfuzz"
	exit
fi

while getopts ":d:f:c:w:" opt; do
	case $opt in
		d)
			DOMAIN="$OPTARG"
			echo "Gathering information for $DOMAIN"
			;;
		\?)
			echo "Invalid operation: -$OPTARG" >&2
			exit 1
			;;
		:)
			echo "Option $OPTARG requires an argument" >&2
			exit 1
			;;
		f)
			OUTDIR="$OPTARG"
			echo "Creating directroy: $OPTARG"
			;;
		c)
			HEADERS="Y"
			;;
		w)
			ISFUZZING="Y"
	esac
done

cat .title.txt

#Creating a directory where all the outputs will be stored

mkdir $OUTDIR

cd $OUTDIR

#Running whois
whois $DOMAIN >> whois.txt


#Running theHarvester and amass

echo "Running TheHarvester..."
theHarvester -d $DOMAIN -b all -f TH_out  1>/dev/null 2>&1

echo -e "theHarvester finished.\n"

echo "Running Amass..."
amass enum -d $DOMAIN -nocolor -o AMS_out.txt -silent

echo -e  "Amass finished.\n"

#Running shcheck and testssl

echo "Running shcheck..."
../shcheck/shcheck.py -j https://$DOMAIN > SHCH_out.json 1>/dev/null 2>&1 i
echo -e "shcheck finished.\n"


echo "Running testssl..."
bash ../testssl.sh/testssl.sh --logfile TESTSSL_out $DOMAIN 1>/dev/null 2>&1
echo -e "testssl finished.\n"

echo "Running DnsRecon..."
dnsrecon -d $DOMAIN -j DNS_out.json
echo -e "DnsRecon finished.\n"

echo "Running WhatWeb..."
whatweb $DOMAIN --log-json=WW_out.json
echo -e "WhatWeb finished.\n"i


function header_if () {

RESPONSE=$(curl -m 5 --connect-timeout 5 -I "$1:$2")

http_status=$(echo "$RESPONSE" | head -n 1 | cut -d' ' -f2)

if [[ $http_status =~ 2[0-9][0-9] ]] || [[ $http_status =~ 3[0-9][0-9] ]]
then
        echo "$RESPONSE" >> headers
fi
	
}



function header_ports ($DOM) {
	
echo -e "\n\n" >> headers
echo "$DOMAIN"
$1="$DOMAIN"
header_if "$1","80"
header_if "$1","443"
header_if "$1","8080" 
header_if "$1","8081"
header_if "$1","3080" 	
header_if "$1","8443"
header_if "$1","4443"
header_if "$1","6443"

}
#Collecting headers with theHarvester links:

if [ $HEADERS == "Y" ]
then
	header_ports("$DOMAIN")

        for i in $(cat TH_out.json | jq -r '.hosts[]')
        do
        	header_ports("$i")
	done

        for i in $(cat TH_out.json | jq -r '.ips[]')
        do
        	header_ports("$i")
	done

fi


#The wfuzz command executes:

if [ $ISFUZZING == "Y" ] || [ $ISFUZZING == "y" ]
then
	echo "Running wfuzz..."
	wfuzz -c -z file,/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt --hh 1 --hc 404 http://$DOMAIN/FUZZ >> out.txt 1>/dev/null 2>&1	echo "wfuzz finished."

echo "Fuzzing... Please wait..."
fi


