#!/bin/bash

# use %24 as $
# use %20 as space
# use %27 as '
thingsName='RaspBudhi%20Pi%202' # Put the things' name to be searched here!
searchResult=`curl -X GET -H "Content-Type: application/json" "http://scratchpad.sensorup.com/OGCSensorThings/v1.0/Things?%24filter=name%20eq%20%27$thingsName%27"`
# if there is no such a thing, then create one, else print the thing's ID number
if [ ${searchResult:14:1} -eq 0 ]; then
	# create a thing
	echo "please create a thing"
else
	thingsID=`echo $searchResult | awk -F"," '{ print $2 }' | awk -F":" '{ print $3 }'`
	echo "The thing's ID is $thingsID"
fi
