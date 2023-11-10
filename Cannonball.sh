#!/bin/bash

cat .title.txt

read -p "Input a domain: " DOMAIN
read -p "Input an output file name: " OUTFILE

echo "Enumeración de SUBDOMINIOS con Amass y TheHarvester:"
wait 2


theHarvester -d $DOMAIN -b all -f $OUTFILE\_TH & amass enum -d $DOMAIN -o ./$OUTFILE

echo "TheHarvester y amass han funcionado correctamente.\n\n"
echo "Iniciando Metagoofil"

wait 2

python3 ./metagoofil/metagoofil.py -d $DOMAIN -f $OUTFILE -n 20 -l 200 -t pdf,doc,xls,ppt,docx,csv,pptx,xlsx

