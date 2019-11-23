#!/bin/bash

#The final deploy or build location of this conky setup
projectDir='/home/saurabhtotey/.conky'

#Stops any existing conky processes if any
pkill -f conky

#Replaces the existing conky setup with this new one
rm -rf $projectDir
cp -Rf ./. $projectDir

#Goes to the output project directory and replaces '{{PROJECT}}' with the path to the real project
cd $projectDir || exit
find . -name '*.lua' -exec sed -i -e "s+{{PROJECT}}+$projectDir+g" {} \;

#Creates a log file to catch any of the conky output
mkdir bin
touch bin/log.txt

#Starts conky in the background
conky -DD -d -c $projectDir/.conkyrc > ./bin/log.txt 2>&1
