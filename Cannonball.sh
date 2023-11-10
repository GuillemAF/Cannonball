#!/bin/bash

read -p "Input a domain: " DOMAIN
read -p "Input an output file name: " OUTFILE

theHarvester -d $DOMAIN -b all -f $OUTFILE\_TH & metagoofil -d $DOMAIN -t pdf,csv,doc,xls,ppt,docx,pptx,xlsx -l 200 -n10 -o ./ -f ./$OUTFILE\_MGF & amass enum -d $DOMAIN -o ./$OUTFILE
