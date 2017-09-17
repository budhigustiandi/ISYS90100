#!/bin/bash

# Enter thing's name as a search parameter
# use %24 as $
# use %20 as space
# use %27 as '
thingsName='RaspBudhi%20Pi%204'

# Search the thing in the server
searchResult=`curl -X GET -H "Content-Type: application/json" "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Things?%24filter=name%20eq%20%27$thingsName%27"`

# If there is no such a thing, then create one, else print the thing's ID number
# For this version, the location is assumed to be a fix one. In the future, mobile location can be used by integrating a GPS receiver into the system
if [ ${searchResult:14:1} -eq 0 ]; then
	echo "The thing you mentioned does not exist. The thing will be created."
	targetUrl="https://scratchpad.sensorup.com/OGCSensorThings/v1.0/Things"
	curl -XPOST -H "Content-type: application/json" -d '{
		"name": "RaspBudhi Pi 4",
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
		}],
		"Datastreams": [{
			"name": "Light Intensity",
			"description": "Datastream for recording light intensity",
			"observationType": "http://www.opengis.net/def/observationType/OGC-OM/2.0/OM_Measurement",
			"unitOfMeasurement": {
				"name": "candela",
				"symbol": "cd",
				"definition": "https://en.wikipedia.org/wiki/Candela"
			},
			"ObservedProperty": {
				"name": "Area light intensity",
				"description": "The degree or intensity of light in the area",
				"definition": "https://en.wikipedia.org/wiki/Luminous_intensity"
			},
			"Sensor": {
				"name": "Grove Light Sensor",
				"description": "Light sensor that detects light intensity",
				"encodingType": "application/pdf",
				"metadata": "https://www.dxterindustries.com/shop/grove-light-sensor.pdf"
			}
		}]
	}' $targetUrl
else
	thingsID=`echo $searchResult | awk -F"," '{ print $2 }' | awk -F":" '{ print $3 }'`
	echo "The thing is already exist and its ID is $thingsID"
fi
