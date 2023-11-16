#!/usr/bin/python3

import requests
import json

    
if __name__ == "__main__":

    with open("TH_out.json", "r") as j:
        TheHarvester = json.load(j)

    for host in TheHarvester["hosts"]:
        try:
            url = "http://" + host
            r = requests.get(url, headers={"Content-Type":"text"})
        except ValueError:
            continue
        else:
            print("host: " + host)
            print(r)
