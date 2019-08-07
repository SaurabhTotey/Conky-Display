#!/bin/bash

#Moves the new config to the location where conky will look for it and use it, replacing the old one
cp ./.conkyrc ~/.conkyrc -f

#Restarts Conky
pkill -f conky
cd ~ || exit
conky -b > /dev/null 2>&1 &
