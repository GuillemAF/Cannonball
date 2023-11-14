#!/usr/bin/python3
import requests
import json


with open("TH_out.json", "r") as j:
    TheHarvester = json.load(j)

for i in TheHarvester["hosts"]:
    response = requests.get(i)
    print(response)
    



