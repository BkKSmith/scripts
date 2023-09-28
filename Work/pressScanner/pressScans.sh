#!/bin/bash

readarray -t machineArray < /home/ksmith/Desktop/pressScanner/machineList.txt
rm /home/ksmith/Desktop/scriptRan.txt
for i in ${machineArray[@]}; do
printf "Scanning for $i\n" >> /home/ksmith/Desktop/scriptRan.txt
nmap -T4 -A -v -Pn $i >> /home/ksmith/Desktop/scriptRan.txt
wait
printf "\n\n" >> /home/ksmith/Desktop/scriptRan.txt
done
