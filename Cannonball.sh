#!/bin/bash

cat .title.txt

# User input: domain & directory

read -p "Input a domain: " DOMAIN
read -p "Input a directory name where the information will be stored: " OUTDIR

sleep 2

#Creating a directory where all the outputs will be stored

mkdir $OUTDIR

cd $OUTDIR

#Running theHarvester and amass
theHarvester -d $DOMAIN -b all -f TH_out 

amass enum -d $DOMAIN -nocolor -o AMS_out

#Running shcheck and testssl
../shcheck/shcheck.py -j https://$DOMAIN > SHCH_out

bash ../testssl.sh/testssl.sh --logfile TESTSSL_out $DOMAIN

#Collecting headers with theHarvester links:

for i in $(cat TH_out.json | jq -r '.hosts[]')
do
        echo "Domain: $i" >> headers
        echo -e "\n" >> headers
	echo "port: 80" >> headers
        curl -I $i >> headers
	echo "port: 443" >> headers
	curl -I $i:443 >> headers
	echo "port: 8080" >> headers
        curl -I $i:8080 >> headers
	echo "port: 8081" >> headers
        curl -I $i:8081 >> headers
	echo "port: 3080" >> headers
        curl -I $i:3080 >> headers
	echo "port: 8443" >> headers
        curl -I $i:8443 >> headers
	echo "port: 4443" >> headers
        curl -I $i:4443 >> headers
	echo "port: 6443" >> headers
        curl -I $i:6443 >> headers
        echo -e "\n\n"
done


for i in $(cat TH_out.json | jq -r '.ips[]')
do
        echo "IP: $i" >> headers
        echo -e "\n" >> headers
	echo "port: 80" >> headers
        curl -I $i >> headers
	echo "port: 443" >> headers
	curl -I $i:443 >> headers
	echo "port: 8080" >> headers
        curl -I $i:8080 >> headers
	echo "port: 8081" >> headers
        curl -I $i:8081 >> headers
	echo "port: 3080" >> headers
        curl -I $i:3080 >> headers
	echo "port: 8443" >> headers
        curl -I $i:8443 >> headers
	echo "port: 4443" >> headers
        curl -I $i:4443 >> headers
	echo "port: 6443" >> headers
        curl -I $i:6443 >> headers
        echo -e "\n\n"
done
