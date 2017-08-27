#!/bin/bash

while [ true ]; do
	measurement=`sudo python convertMeasurement.py | awk {'print $6'}`
	# measurement=`sudo python convertMeasurement.py`
	year=`date +%Y`
	month=`date +%m`
	day=`date +%d`
	hourMinuteSecond=`date | awk {'print $4'}`
	datastreamID=1063643
	targetUrl="https://scratchpad.sensorup.com/OGCSensorThings/v1.0/Observations"
	curl -X POST -H "Content-Type: application/json" -d '{"phenomenonTime": "'$year'-'$month'-'$day'T'$hourMinuteSecond'.000Z", "resultTime": "'$year'-'$month'-'$day'T'$hourMinuteSecond'.000Z", "result": '$measurement', "Datastream": {"@iot.id": '$datastreamID'}}' $targetUrl
	# curl -X POST -H "Content-Type: application/json" -d '$measurement' $targetUrl
	sleep 5
done
