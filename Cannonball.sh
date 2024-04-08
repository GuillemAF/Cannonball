#/bin/bash


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
cat TH_out.json | jq -r '.emails[]' > emails.txt

echo -e "theHarvester finished.\n"

echo "Running Amass..."
amass enum -d $DOMAIN -nocolor -dir .  -silent

sqlite3 amass.sqlite "SELECT table1.content,assets.content,relations.type  FROM (SELECT assets.id AS id, assets.content AS content FROM assets WHERE assets.content LIKE '%name%$DOMAIN%') AS table1 INNER JOIN relations,assets WHERE relations.from_asset_id=table1.id AND relations.to_asset_id=assets.id AND (relations.type!=\"ns_record\" AND relations.type!=\"mx_record\");" -json > AMS_out.txt

cp ../scriptparseador.py .
python3 scriptparseador.py 

cat records.json | jq -r '.[].reference, .[].content' | jq -r '.name, .address' > spiderfootinput.txt


archivo="spiderfootinput.txt"
archivo_temporal="temp.txt"

while IFS= read -r linea; do
    if [[ "$linea" != *null* ]]; then
        echo "$linea" >> "$archivo_temporal"
    fi
done < "$archivo"

# Opción 1: Sobrescribe el archivo original con el temporal
mv "$archivo_temporal" "$archivo"

awk '!seen[$0]++' "spiderfootinput.txt" > "spiderf.txt"

echo -e "Amass finished.\n"


#The wfuzz command executes:

if [ "$ISFUZZING" == "Y" ] || [ "$ISFUZZING" == "y" ]
then
	echo "Running wfuzz..."
	wfuzz -f WFZZ_out.json,json -c -z file,/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt --hh 1 --hc 404 http://$DOMAIN/FUZZ 1>/dev/null 2>&1
	echo "wfuzz finished."
fi


# Here we pull together all the documents this tool has created to make a very big json file


mkdir ./DNSrecon-output
echo "Running DnsRecon..."
for i in $(cat spiderf.txt)
do
	dnsrecon -d $i -j ./DNSrecon-output/DNS-$i.json 1>/dev/null 2>&1
done
echo -e "DnsRecon finished.\n"



mkdir ./Whatweb-output
echo "Running Whatweb..."
for i in $(cat spiderf.txt)
do
	whatweb $i --log-json=./Whatweb-output/WW-$i.json 1>/dev/null 2>&1
	jq '.[].plugins' ./Whatweb-output/WW-$i.json > ./Whatweb-output/Techs-$i.json
done
echo -e "Whatweb finished.\n"




mkdir ./shcheck-output
echo "Running shcheck..."
for i in $(cat spiderf.txt)
do
	python3 ../shcheck/shcheck.py -j https://$i > ./shcheck-output/SHCH-$i.json 1>/dev/null 2>&1 
	jq '.["https://'"$i"'/"].missing' ./shcheck-output/SHCH-$i.json > ./shcheck-output/checks-$i.json
done
echo -e "shcheck finished.\n"




mkdir ./testssl-output
echo "Running testssl..."
for i in $(cat spiderf.txt)
do
	../testssl.sh/testssl.sh --jsonfile ./testssl-output/TESTSSL-$i.json $i 1>/dev/null 2>&1
	jq '.[] | select(.severity != "OK" and .severity != "INFO") | {id: .id, ip: .ip, port: .port, severity: .severity, finding: .finding}' ./testssl-output/TESTSSL-$i.json > ./testssl-output/encryptInfo-$i.json
done
echo -e "testssl finished.\n"




mkdir ./spiderfoot-output
for i in $(cat spiderf.txt)
do
	spiderfoot -s $i -o json > ./spiderfoot-output/sf-$i.json
	jq '.[] | select(.module == "sfp_ipinfo") | {data: .data, source: .source}' ./spiderfoot-output/sf-$i.json > ./spiderfoot-output/direcciones_$i.json
	jq '.[] | select(.module == "sfp_email") | .data' ./spiderfoot-output/sf-$i.json > ./spiderfoot-output/emails_$i.json
	jq '.[] | select(.type == "HTTP Headers") | {data: .data}' ./spiderfoot-output/sf-$i.json > ./spiderfoot-output/headers_$i.json
	jq '.[] | select(.type == "IP Address") | {data: .data}'  ./spiderfoot-output/sf-$i.json > ./spiderfoot-output/IP_$i.json

done

for i in $(cat emails.txt)
do
	spiderfoot -s $i -o json > ./spiderfoot-output/sf-$i.json
done


../jsonfinal.sh spiderf.txt

for i in $(cat spiderf.txt)
do
jq -s 'add' ./DNSrecon-output/DNS-$i.json ./Whatweb-output/Techs-$i.json ./shcheck-output/checks-$i.json ./spiderfoot-output/direcciones_$i.json ./spiderfoot-output/emails-$i.json ./spiderfoot-output/headers_$i.json ./spiderfoot-output/IP_$i.json > info-$i.json
done



# Leer la lista de subdominios
subdominios=$(jq -r '.subdominios[]' output.json)

# Inicializar el objeto JSON final
json_final="{\"subdominios\": []}"

# Iterar sobre cada subdominio
for subdominio in $subdominios; do
    # Leer el archivo JSON correspondiente al subdominio
    info_subdominio=$(jq -s 'add' info-$subdominio.json)
    
    # Agregar la información del subdominio al objeto JSON final
    json_final=$(echo $json_final | jq --argjson info_subdominio "$info_subdominio" '.subdominios += [$info_subdominio]')
done

# Imprimir el JSON final
echo $json_final






