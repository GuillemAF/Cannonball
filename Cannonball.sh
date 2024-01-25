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

result=$(sqlite3 amass.sqlite -json "SELECT table1.content,assets.content FROM (SELECT assets.id AS id, assets.content AS content FROM assets WHERE assets.content LIKE '%name%$DOMAIN%') AS table1 INNER JOIN relations,assets WHERE relations.from_asset_id=table1.id AND relations.to_asset_id=assets.id;" | jq -c '.[]' | jq -c '(.content | fromjson) + (.content | fromjson)' | jq -r '"\(.name?) \(.address?)"' | tr ' ' '\n')

filtered_result=""

for i in $result
do 
    if [ "$i" != "null" ]; then
        filtered_result="$filtered_result\n$i"
    fi
done

echo "$filtered_result" >> AMS_out.txt


echo -e  "Amass finished.\n"

#Running shcheck and testssl

echo "Running shcheck..."
../shcheck/shcheck.py -j https://$DOMAIN > SHCH_out.json 1>/dev/null 2>&1 
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

RESPONSE=$(curl -L -m 5 --connect-timeout 5 -I "$1:$2")

http_status=$(echo "$RESPONSE" | head -n 1 | cut -d' ' -f2)

if [[ $http_status =~ 2[0-9][0-9] ]]
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
../shcheck/shcheck.py -j https://$1 >> ./shcheck/checklog_$1 
echo -e "\n"
echo -e "\n"
}



function header_ports () {
	
echo -e "\n\n" >> headers
echo "$1"
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
	for i in $(cat AMS_out.txt)
	do
		header_ports "$i"

		if [ $ENCRYPT == "Y" ]
		then
			test_check "$i"
		fi
	done
fi
#The wfuzz command executes:

if [ $ISFUZZING == "Y" ] || [ $ISFUZZING == "y" ]
then
	echo "Running wfuzz..."
	wfuzz -f WFZZ_out.json,json -c -z file,/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt --hh 1 --hc 404 http://$DOMAIN/FUZZ 1>/dev/null 2>&1
	echo "wfuzz finished."
fi


# Here we pull together all the documents this tool has created to make a very big json file

# Input file name
INPUT_FILE="headers"

# Intermediate JSON file name
INTERMEDIATE_FILE="headers.json"

# Output JSON file name after cleaning
OUTPUT_FILE="cleaned_headers.json"

# Create an empty JSON file
echo '[]' > "$INTERMEDIATE_FILE"

# Variable to store the current block
BLOCK=""

# Process each line of the file
while IFS= read -r LINE; do
    # If the line is empty, process the current block
    if [ -z "$LINE" ]; then
        # Create a JSON object with the current block and add it to the list
        NEW_JSON=$(jq --arg block "$BLOCK" '. += [{"header": $block}]' "$INTERMEDIATE_FILE")

        # Save the result in the intermediate JSON file
        echo "$NEW_JSON" > "$INTERMEDIATE_FILE"

        # Reset the block for the next iteration
        BLOCK=""
    else
        # Add the current line to the block
        BLOCK+="$LINE\n"
    fi
done < "$INPUT_FILE"

# Use jq to filter and remove objects with empty "header" fields
jq 'map(select(.header != ""))' "$INTERMEDIATE_FILE" > "$OUTPUT_FILE"

echo "Process completed. The result is in $OUTPUT_FILE."

jq -s '.'  SHCH_out.json TH_out.json WW_out.json AMS_out.json cleaned_headers.json  >> final.json
