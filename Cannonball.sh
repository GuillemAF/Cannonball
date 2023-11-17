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

echo "All the tools worked correctly. Do you want to extract http headers?"

read -p "Y/n: " HEADERS

if [ $HEADERS == "Y" ] || [ $HEADERS == "y" ]
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



