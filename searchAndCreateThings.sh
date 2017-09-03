#!/bin/bash

# use %24 as $
# use %20 as space
# use %27 as '
thingsName='RaspBudhi%20Pi%203' # Put the things' name to be searched here!
searchResult=`curl -X GET -H "Content-Type: application/json" "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Things?%24filter=name%20eq%20%27$thingsName%27"`
# if there is no such a thing, then create one, else print the thing's ID number
if [ ${searchResult:14:1} -eq 0 ]; then
	targetUrl="https://scratchpad.sensorup.com/OGCSensorThings/v1.0/Things"
	curl -XPOST -H "Content-type: application/json" -d '{
		"name": "RaspBudhi Pi 3",
		"description": "IoT system based on OGC SensorThings API",
		"properties": {
			"base hardware": "Raspberry Pi 3",
			"extension hardware": "Grovepi"
		},
		"Locations": [{
			"name": "Home Laboratory",
			"description": "Laboratory at home",
			"encodingType": "application/vnd.geo+json",
			"location": {
				"type": "Point",
				"coordinates": [144.960, -37.808]
			}
		}]
	}' $targetUrl
else
	thingsID=`echo $searchResult | awk -F"," '{ print $2 }' | awk -F":" '{ print $3 }'`
	echo "The thing is already exist and its ID is $thingsID"
fi
