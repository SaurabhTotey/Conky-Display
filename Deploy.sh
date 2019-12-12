#!/bin/bash

#The final deploy or build location of this conky setup
projectDir='/home/saurabhtotey/.conky'

#Stops any existing conky processes if any
killall conky > /dev/null 2>&1

#Replaces the existing conky setup with this new one
rm -rf $projectDir
cp -Rf ./. $projectDir

#Goes to the output project directory
cd $projectDir || exit

#Creates a startup script in the output directory that allows the currently deployed conky setup to be easily run and logged
runConkyScript=(
"#!/bin/bash"
"cd $projectDir || exit"
"killall conky > /dev/null 2>&1"
"numberOfFiles=\$(find ./bin | wc -l)"
"numberOfFiles=\$((numberOfFiles - 1))"
"logFileLocation=\"./bin/log\$numberOfFiles.txt\""
"touch \$logFileLocation"
"dateTimeInfo=\$(date \"+%d/%m/%Y %H:%M:%S\")"
"printf \"%s\n\" \"Running conky at \$dateTimeInfo.\" \"\" > \$logFileLocation"
"conky -DD -d -c $projectDir/.conkyrc >> \$logFileLocation 2>&1"
)

touch ./RunConky.sh
printf "%s\n" "${runConkyScript[@]}" > RunConky.sh
chmod +x ./RunConky.sh

#Gets any relevant git info
gitCommitInfo=$(git log -1)
isCleanMessage="This deployed version has changes that have not been committed as of the time of deploy."
if output=$(git diff --exit-code) && [ -z "$output" ]; then
	isCleanMessage="This deployed version has no uncommited changes as of the time of deploy."
fi

#Puts deployment info in the bin
mkdir ./bin/
touch ./bin/DeployInfo.txt
dateTimeInfo=$(date "+%d/%m/%Y %H:%M:%S")
printf "%s\n" "Deploy time: $dateTimeInfo." "$isCleanMessage" "" "Latest git commit as of time of deploy:" "$gitCommitInfo" > ./bin/DeployInfo.txt

#Removes all unnecessary files from the project in the output
rm -rf ./.git
rm -rf ./.gitignore
rm -rf ./Deploy.sh

#Replaces '{{PROJECT}}' with the path to the real project
fileGlobs=(".conkyrc" "*.lua" "*.txt")
for glob in "${fileGlobs[@]}"
do
	find . -name "$glob" -exec sed -i -e "s+{{PROJECT}}+$projectDir+g" {} \;
done

#Starts conky using the newly created startup script
./RunConky.sh
