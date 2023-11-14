#!/bin/bash

cat .title.txt

read -p "Input a domain: " DOMAIN
read -p "Input a directory name where the information will be stored: " OUTDIR

echo "Enumeración de SUBDOMINIOS con Amass y TheHarvester:"
sleep 2

mkdir $OUTDIR

theHarvester -d $DOMAIN -b all -f TH_out & amass enum -d $DOMAIN -nocolor -o ./$OUTDIR/AMS_out




echo "TheHarvester y amass han funcionado correctamente.\n\n"

sleep 2









