#!/bin/bash

#Checks to see if the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

#Check the number of command line arguments
if [ "$#" -ne 1 ]; then
	echo "Usage: ./$0 <ipAddress>"
	exit 1
fi

#Create a directory to hold all of the output files that come from this script
mkdir nmapScans
mkdir nmapScans/$1
'
echo ____Peforming Syn Scan on Host $1____
#Run a NMAP Syn Scan
sudo nmap -sS $1 -p- -oN nmapScans/$1/synScan -oG nmapScans/$1/synScan.grep | grep open | cut -d "/" -f 1 > nmapScans/$1/hostPorts
echo ____Syn Scan Done____

echo ____Performing TCP Connect Scan on Host $1____
#Run a nmap connect scan against the target. 
nmap -sT -sV --version-intensity 5 -oN nmapScans/$1/Versionscan -oG nmapScans/$1/versionScan.grep -p $(tr '\n' , <nmapScans/$1/hostPorts | sed 's/,*$//g') $1 >/dev/null
echo ____TCP Connect Scan Done____

echo ____Running Fingerprint Scan on Host $1____
#Runs a Fingerprint Scan Against the target
nmap -A -oN nmapScans/$1/fingerprintScan -oG nmapScans/$1/fingerprintScan.grep -p $(tr '\n' , <nmapScans/$1/hostPorts | sed 's/,*$//g') $1 >/dev/null
echo ____Fingerprint Scan Finished____


echo ___Starting Vuln Enum on Host____
mkdir nmapScans/$1/vulnScans
:'


#Automatically performs Vuln Enumerations
for openPort in $(cat nmapScans/$1/hostPorts);
do
	echo "---> Checking Port $openPort"
	#Scans for vulns on port 20
        if [ $openPort -eq 20 ]; then
                nmap -p $openPort -oN nmapScans/$1/vulnScans/port20 -oG nmapScans/$1/vulnScans/port20.grep --script=ftp* $1 > /dev/null
        fi

	
	#Scans for vulns on port 22
	if [ $openPort -eq 22 ]; then
                nmap -p $openPort -oN nmapScans/$1/vulnScans/port22 -oG nmapScans/$1/vulnScans/port22.grep --script=ssh* $1 > /dev/null
        fi	
	
	#Scans for SMTP Vulns
	if [ $openPort -eq 25 ] || [ $openPort -eq 587 ] || [ $openPort -eq 465 ]; then
                nmap -p $openPort -oN nmapScans/$1/vulnScans/SMTP -oG nmapScans/$1/vulnScans/SMTP.grep --script=smtp* $1 > /dev/null
        fi
	

	#Scans for vulns on port 80
	if [ $openPort -eq 80 ]; then
		nmap -p $openPort -oN nmapScans/$1/vulnScans/port80 -oG nmapScans/$1/vulnScans/port80.grep --script=http* $1 > /dev/null
	fi
	
	#Scans for vulns on port 443
	if [ $openPort -eq 443 ]; then
                nmap -p $openPort -oN nmapScans/$1/vulnScans/port443 -oG nmapScans/$1/vulnScans/port443.grep --script=ssl*,http* $1 > /dev/null
        fi

	#Scans for SMB vulns
 	if [ $openPort -eq 135  ] || [ $openPort -eq 139  ] || [ $openPort -eq 445  ] ; then
                nmap -p $openPort -oN nmapScans/$1/vulnScans/smb -oG nmapScans/$1/vulnScans/smb.grep --script=smb* $1
        fi


done
