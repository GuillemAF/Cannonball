# Cannonball
Cannonball is a pentest tool used for information gathering and OSINT. It's centered in enterprise security where you'll have to document and download what you find in a very structured way. This tool is a cluster of many local and online OSINT softwares created by other users. What I've made it's just put all of those together.  

## Installation guide
To install this package you will need:
 - A linux machine (Kali is recomended because has many of the tools this script use already installed)
 - Github installed
 - TheHarvester installed
 - Amass installed  

To proceed with the installation you'll have to run this command on your bash shell:

```bash
git clone https://github.com/GuillemAF/Cannonball.git
```
also you will have to have TheHarvester and Amass isntalled too. You can do this by typing:

```bash
apt-get install theharvester & apt-get install amass
```

That's it. You have succesfully installed Cannonball on your machine.

## How does it work?
When you have completed the process of installation, you will have to execute: 
```bash
bash Cannonball.sh
```
Then a text appears. You'll have to introduce your domain and your directory name and wait. When the process is finished, you will have a folder with the name that you introduced previousley. Inside you'll find all the output files ready to be documented.  
This way you can have as many directories as you want containing the domains that you want. 


### What modules does Cannonball use?
This program it's a bash script that uses different modules and OSINT tools. At the moment we are using this ones:
* TheHarvester
* Amass
* Shcheck
* Testssl

## Credits:
Created by: Guillem Agulló
Aktios security SL.


