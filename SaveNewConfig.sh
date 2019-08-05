#!/bin/bash

#Moves the currently in-use config to the old-version folder
cp ~/.conkyrc ./old-version/.conkyrc -f

#Commits the now-moved config into version history so that it can be referenced later if necessary
cd ./old-version || exit
versionNumber=$(git rev-list --all --count)
git add -A > /dev/null 2>&1 &
git commit -m "$versionNumber" > /dev/null 2>&1 &
cd ..

#Moves the new config to the location where conky will look for it and use it, replacing the old one
cp ./.conkyrc ~/.conkyrc -f

#Restarts Conky
pkill -f conky
conky -b > /dev/null 2>&1 &
