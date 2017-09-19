#!/bin/bash

# Enter thing's name as a search parameter
# use %24 as $
# use %20 as space
# use %27 as '
thingsName='RaspBudhi%20Pi%2012'

# Search the thing in the server
searchResult=`curl -X GET -H "Content-Type: application/json" "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Things?%24filter=name%20eq%20%27$thingsName%27"`

# If there is no such a thing, then create one, else print the thing's ID number
# For this version, the location is assumed to be a fix one. In the future, mobile location can be used by integrating a GPS receiver into the system
if [ ${searchResult:14:1} -eq 0 ]; then
	echo "The thing you mentioned does not exist. The thing will be created."
	targetUrl="https://scratchpad.sensorup.com/OGCSensorThings/v1.0/Things"
	curl -XPOST -H "Content-Type: application/json" -d '{
		"name": "RaspBudhi Pi 12",
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

	# Find the thing's ID
	searchResult=`curl -X GET -H "Content-Type: application/json" "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Things?%24filter=name%20eq%20%27$thingsName%27"`
        thingID=`echo $searchResult | awk -F"," '{ print $2 }' | awk -F":" '{ print $3 }'`
        echo "The thing was succesfully created. The thing's ID is $thingID"

	# Add datastream(s) here
	targetUrl="https://scratchpad.sensorup.com/OGCSensorThings/v1.0/Things($thingID)/Datastreams"
	curl -XPOST -H "Content-Type: application/json" -d '{
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
	}' $targetUrl
	curl -XPOST -H "Content-Type: application/json" -d '{
               	"name": "Moisture Level",
               	"description": "Datastream for recording moisture level",
               	"observationType": "http://www.opengis.net/def/observationType/OGC-OM/2.0/OM_Measurement",
               	"unitOfMeasurement": {
                       	"name": "per cent",
                       	"symbol": "%",
                       	"definition": "https://en.wikipedia.org/wiki/Moisture_analysis"
               	},
               	"ObservedProperty": {
                       	"name": "Area moisture level",
                       	"description": "The level of moisture in the area",
                       	"definition": "https://en.wikipedia.org/wiki/Moisture_analysis"
               	},
               	"Sensor": {
                       	"name": "Grove Moisture Sensor",
                       	"description": "Sensor that measures moisture level",
                       	"encodingType": "application/pdf",
                       	"metadata": "https://www.dxterindustries.com/shop/grove-moisture-sensor.pdf"
               	}
	}' $targetUrl
else
	# Find the thing's ID
	thingID=`echo $searchResult | awk -F"," '{ print $2 }' | awk -F":" '{ print $3 }'`
	echo "The thing is already exist and its ID is $thingID"

	# Read measurement(s) from sensor(s) and upload it (them) to the server
	while [ true ]; do
		lightIntensity=`sudo python readSensor.py | awk -F"," '{ print $1 }'`
		moistureLevel=`sudo python readSensor.py | awk -F"," '{ print $2 }'`
		year=`date +%Y`
        	month=`date +%m`
        	day=`date +%d`
        	hourMinuteSecond=`date | awk {'print $4'}`
		searchResult=`curl -X GET -H "Content-Type: application/json" "https://scratchpad.sensorup.com/OGCSensorThings/v1.0/Things($thingID)/Datastreams"`
		numberOfDatastream=`echo $searchResult | awk -F"value" '{ print $1 }' | awk -F":" '{ print $2 }' | awk -F"," '{ print $1 }'`
		if [ $numberOfDatastream -eq 1 ]; then
			echo "There is 1 datastream detected."
		else
			echo "There are $numberOfDatastream datastreams detected."
		fi
        	targetUrl="https://scratchpad.sensorup.com/OGCSensorThings/v1.0/Observations"

		# Find the datastream ID for light intensity
                datastreamID=`echo $searchResult | awk -F"@iot.id" '{ print $3 }' | awk -F":" '{ print $2 }' | awk -F"," '{ print $1 }'`
		echo "Light Intensity = $lightIntensity"
		echo "Datastream ID is $datastreamID."
		echo "Uploading to the server..."

		# Upload the light intensity measurement into the server
		curl -X POST -H "Content-Type: application/json" -d '{
			"phenomenonTime": "'$year'-'$month'-'$day'T'$hourMinuteSecond'.000Z",
			"resultTime": "'$year'-'$month'-'$day'T'$hourMinuteSecond'.000Z",
			"result": '$lightIntensity',
			"Datastream": {"@iot.id": '$datastreamID'}
		}' $targetUrl

		# Find the datastream ID for moisture level
		datastreamID=`echo $searchResult | awk -F"@iot.id" '{ print $2 }' | awk -F":" '{ print $2 }' | awk -F"," '{ print $1 }'`
		echo "Moisture Level = $moistureLevel"
		echo "Datastream ID is $datastreamID."
		echo "Uploading to the server..."

		# Upload the moisture measurement into the server
                curl -X POST -H "Content-Type: application/json" -d '{
                        "phenomenonTime": "'$year'-'$month'-'$day'T'$hourMinuteSecond'.000Z",
                        "resultTime": "'$year'-'$month'-'$day'T'$hourMinuteSecond'.000Z",
                        "result": '$moistureLevel',
                        "Datastream": {"@iot.id": '$datastreamID'}
                }' $targetUrl

		sleep 5
	done
fi
