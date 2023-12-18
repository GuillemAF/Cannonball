#!/bin/bash


if [ $1 == "-h" ] || [ $1 == "--help" ]
then
	echo -e "Cannonball is used to gather open source intelligence (OSINT) on a domain. All the information that this script gathers, will be downloaded for a later documentation.\n\n Options: \n\n-d	Input domain.\n-f	Input the name of the folder.\n-c	Extract headers with curl\n-w	Webfuzzing with wfuzz\n-e	Exctract encryption information about all the subdomains gathered by theharvester and amass"
	exit
fi

while getopts ":d:f:c:w:e" opt; do
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
			;;
		e)
			ENCRYPT="Y"
			;;
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
amass enum -d $DOMAIN -nocolor -dir .  -silent

sqlite3 amass.sqlite "SELECT content FROM assets;" >> AMS_out.json

echo -e  "Amass finished.\n"

#Running shcheck and testssl

echo "Running shcheck..."
../shcheck/shcheck.py -j https://$DOMAIN > SHCH_out.json 1>/dev/null 2>&1 i
echo -e "shcheck finished.\n"


echo "Running testssl..."
bash ../testssl.sh/testssl.sh --logfile TESTSSL_out $DOMAIN 1>/dev/null 2>&1
echo -e "testssl finished.\n"

echo "Running DnsRecon..."
dnsrecon -d $DOMAIN -j DNS_out.json 1>/dev/null 2>&1
echo -e "DnsRecon finished.\n"

echo "Running WhatWeb..."
whatweb $DOMAIN --log-json=WW_out.json 1>/dev/null 2>&1
echo -e "WhatWeb finished.\n"i


#This function header_if does a curl and decides wether or not to print it in the headers file


function header_if () {

RESPONSE=$(curl -m 5 --connect-timeout 5 -I "$1:$2")

http_status=$(echo "$RESPONSE" | head -n 1 | cut -d' ' -f2)

if [[ $http_status =~ 2[0-9][0-9] ]] || [[ $http_status =~ 3[0-9][0-9] ]]
then
	echo "port: $2" >> headers
        echo "$RESPONSE" >> headers
fi
	
}

#This function test_check does a shcheck to a certain domain "$1" and saves the output in check subdomains

mkdir shcheck

function test_check () {
echo "$1: "
echo -e "\n"
../shcheck/shcheck.py -j https://$1 >> check_subdomains/check_$1 $1 
echo -e "\n"
echo -e "\n"
}


mkdir testssl_subdomains

function check_test () {
echo "$1: "
echo -e "\n"
../testssl.sh/testssl.sh --json-pretty ./testssl_subdomains/test_$1 --append $1 
echo -e "\n"
echo -e "\n"
}

function header_ports () {
	
echo -e "\n\n" >> headers
echo "$DOMAIN"
$1="$DOMAIN"
header_if "$1" 80
header_if "$1" 443
header_if "$1" 8080 
header_if "$1" 8081
header_if "$1" 3080 	
header_if "$1" 8443	
header_if "$1" 4443
header_if "$1" 6443

}
#Collecting headers with theHarvester links:

if [ $HEADERS == "Y" ]
then
	header_ports "$DOMAIN"

        for i in $(cat TH_out.json | jq -r '.hosts[]')
        do
        	header_ports "$i"
	done

        for i in $(cat TH_out.json | jq -r '.ips[]')
        do
        	header_ports "$i"
	done

fi

if [ $ENCRYPT == "Y" ]
then
	test_check "$DOMAIN"
	check_test "$DOMAIN"

        for i in $(cat TH_out.json | jq -r '.hosts[]')
        do
		test_check "$i"
		check_test "$i"
	done

        for i in $(cat TH_out.json | jq -r '.ips[]')
        do
		test_check "$i"
		check_test "$i"
	done

fi


if [ $HEADERS == "Y" ]
then 
	for i in $(cat AMS_out.json | jq -r '.[]')
	do
		header_ports "$i"

		if [ $ENCRYPT == "Y" ]
		then
			test_check "$i"
			check_test "$i"
		fi
	done
fi
#The wfuzz command executes:

if [ $ISFUZZING == "Y" ] || [ $ISFUZZING == "y" ]
then
	echo "Running wfuzz..."
	wfuzz -c -z file,/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt --hh 1 --hc 404 http://$DOMAIN/FUZZ >> out.txt 1>/dev/null 2>&1	echo "wfuzz finished."

echo "Fuzzing... Please wait..."
fi


