#!/bin/bash

#The final deploy or build location of this conky setup
projectDir='/home/saurabhtotey/.conky'

#Stops any existing conky processes if any
pkill -f conky

#Replaces the existing conky setup with this new one
rm -rf $projectDir
cp -Rf ./. $projectDir

#Goes to the output project directory
cd $projectDir || exit

#Creates a startup script in the output directory that allows the currently deployed conky setup to be restarted
#TODO: make startup create separate logs for each run
touch ./RunConky.sh
printf "%s\n" "#!/bin/bash" "cd {{PROJECT}} || exit" "killall conky > /dev/null 2>&1" "rm -rf ./bin/" "mkdir ./bin" "touch ./bin/log.txt" "conky -DD -d -c $projectDir/.conkyrc > ./bin/log.txt 2>&1" > RunConky.sh
chmod +x ./RunConky.sh

#Replaces '{{PROJECT}}' with the path to the real project
fileGlobs=(".conkyrc" "*.lua" "*.txt" "*.sh")
for glob in "${fileGlobs[@]}"
do
	find . -name "$glob" -exec sed -i -e "s+{{PROJECT}}+$projectDir+g" {} \;
done

#Removes all unnecessary files from the project in the output or build directory and creates any necessary ones
rm -rf ./.git
rm -rf ./.gitignore
rm -rf ./Deploy.sh
mkdir ./bin/ #This will be deleted and recreated with the startup script, but it assumes that a bin directory exists, so we are creating one just in case here
#TODO: put a file in ./bin/ about some deployment info (eg. latest git commit/sha, deployment time)

#Starts conky using the newly created startup script
./RunConky.sh
