#!/bin/bash

#Moves the new config to the location where conky will look for it and use it, replacing the old one
cp ./.conkyrc ~/.conkyrc -f

#Deletes and recreates the log file
rm -rf ./bin/log.txt
touch ./bin/log.txt

#Restarts Conky
pkill -f conky
cd ~ || exit
conky -b > ~/Development/Personal/Conky-Display/bin/log.txt 2>&1 &
