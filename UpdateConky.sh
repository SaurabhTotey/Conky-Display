#!/bin/bash

#Replaces the existing conky setup with this new one
rm -rf ~/.conky
cp -Rf ./. ~/.conky/

#Restarts Conky
pkill -f conky
cd ~/.conky || exit
conky -DD -d -c /home/saurabhtotey/.conky/.conkyrc > ./bin/log.txt 2>&1
