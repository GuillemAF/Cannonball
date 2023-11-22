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
theHarvester -d $DOMAIN -b all -f TH_out 1>/dev/null 2>&1

echo -e "theHarvester finished.\n"

echo "Running Amass..."
amass enum -d $DOMAIN -nocolor -o AMS_out.txt -silent

echo -e "Amass finished.\n"

#Running shcheck and testssl

echo "Running shcheck..."
../shcheck/shcheck.py -j https://$DOMAIN > SHCH_out.json 1>/dev/null 2>&1 i
echo "shcheck finished.\n"


echo "Running testssl..."
bash ../testssl.sh/testssl.sh --logfile TESTSSL_out $DOMAIN 1>/dev/null 2>&1
echo "testssl finished."

#Collecting headers with theHarvester links:

if [ $HEADERS == "Y" ]
then
        echo "Domain: $DOMAIN"
        echo "port: 80" >> headers
        curl -m 5 --connect-timeout 5 -I $DOMAIN >> headers
        echo "port: 443" >> headers
        curl -m 5 --connect-timeout 5 -I $DOMAIN:443 >> headers
        echo "port: 8080" >> headers
        curl -m 5 --connect-timeout 5 -I $DOMAIN:8080 >> headers
        echo "port: 8081" >> headers
        curl -m 5 --connect-timeout 5 -I $DOMAIN:8081 >> headers
        echo "port: 3080" >> headers
        curl -m 5 --connect-timeout 5 -I $DOMAIN:3080 >> headers
        echo "port: 8443" >> headers
        curl -m 5 --connect-timeout 5 -I $DOMAIN:8443 >> headers
        echo "port: 4443" >> headers
        curl -m 5 --connect-timeout 5 -I $DOMAIN:4443 >> headers
        echo "port: 6443" >> headers
        curl -m 5 --connect-timeout 5 -I $DOMAIN:6443 >> headers
        echo -e "\n\n"

        for i in $(cat TH_out.json | jq -r '.hosts[]')
        do
                echo "Domain: $i" >> headers
                echo -e "\n" >> headers
                echo "port: 80" >> headers
                curl -m 5 --connect-timeout 5 -I $i >> headers
                echo "port: 443" >> headers
                curl -m 5 --connect-timeout 5 -I $i:443 >> headers
                echo "port: 8080" >> headers
                curl -m 5 --connect-timeout 5 -I $i:8080 >> headers
                echo "port: 8081" >> headers
                curl -m 5 --connect-timeout 5 -I $i:8081 >> headers
                echo "port: 3080" >> headers
                curl -m 5 --connect-timeout 5 -I $i:3080 >> headers
                echo "port: 8443" >> headers
                curl -m 5 --connect-timeout 5 -I $i:8443 >> headers
                echo "port: 4443" >> headers
                curl -m 5 --connect-timeout 5 -I $i:4443 >> headers
                echo "port: 6443" >> headers
                curl -m 5 --connect-timeout 5 -I $i:6443 >> headers
                echo -e "\n\n"
        done

        for i in $(cat TH_out.json | jq -r '.ips[]')
        do
                echo "IP: $i" >> headers
                echo -e "\n" >> headers
                echo "port: 80" >> headers
                curl -m 5 --connect-timeout 5 -I $i >> headers
                echo "port: 443" >> headers
                curl -m 5 --connect-timeout 5 -I $i:443 >> headers
                echo "port: 8080" >> headers
                curl -m 5 --connect-timeout 5 -I $i:8080 >> headers
                echo "port: 8081" >> headers
                curl -m 5 --connect-timeout 5 -I $i:8081 >> headers
                echo "port: 3080" >> headers
                curl -m 5 --connect-timeout 5 -I $i:3080 >> headers
                echo "port: 8443" >> headers
                curl -m 5 --connect-timeout 5 -I $i:8443 >> headers
                echo "port: 4443" >> headers
                curl -m 5 --connect-timeout 5 -I $i:4443 >> headers
                echo "port: 6443" >> headers
                curl -m 5 --connect-timeout 5 -I $i:6443 >> headers
                echo -e "\n\n"
        done

fi


#The wfuzz command executes:

if [ $ISFUZZING == "Y" ] || [ $ISFUZZING == "y" ]
then
	echo "Running wfuzz..."
	wfuzz -c -z file,/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt --hh 1 --hc 404 http://$DOMAIN/FUZZ >> out.txt 1>/dev/null 2>&1	echo "wfuzz finished."

echo "Fuzzing... Please wait..."
fi



