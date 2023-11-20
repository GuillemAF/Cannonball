# Cannonball
Cannonball is a pentest tool used for information gathering and OSINT. It's centered in enterprise security where you'll have to document and download what you find in a very structured way. This tool is a cluster of many local and online OSINT softwares created by other users. What I've made it's just put all of those together.  

### What modules does Cannonball use?
This program it's a bash script that uses different modules and OSINT tools. At the moment we are using this ones:
* TheHarvester
* Amass
* Shcheck
* Testssl
* Wfuzz

## Installation guide
This tool requires a little bit of a "set up". Here are the instructions:  

To proceed with the installation you'll have to run this command on your bash shell:

```bash
git clone https://github.com/GuillemAF/Cannonball.git
```

Another thing you have to do to get this program running properly, is to install this github repositories and have them in the same directory ("Cannonball"). Cannonball.sh script is prepeared to launch those programs from that ubication.  
To do this, you will have to run the following commands:  
  
(Make sure that you are in "Cannonball" directory)  

```bash
git clone https://github.com/drwetter/testssl.sh.git
git clone https://github.com/santoru/shcheck.git
```
also, you will have to have TheHarvester and Amass isntalled too. You can do this by typing:

```bash
sudo apt-get install theharvester & sudo apt-get install amass
```

Then install wfuzz if you don't have it already. kali linux has it already installed so its a lot easier.
```bash
sudo apt-get install -y wfuzz
```

That's it. You have succesfully installed Cannonball on your machine.

## How does it work?
When you have completed the process of installation, you will have to execute: 
```bash
bash Cannonball.sh
```
Then a text appears. You'll have to introduce your domain and your directory name and wait. At one point, the script will ask you if you want to extract http headers. Click yes if you want to, no if you don't. Then it will ask if you want to webfuzz the domain. Y for yes N or anything else for no. When the process is finished, you will have a folder with the name that you introduced previousley. Inside you'll find all the output files ready to be documented.  
This way you can have as many directories as you want containing the domains that you want. 

## Credits:
Created by: Guillem Agulló
Aktios security SL.


