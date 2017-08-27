# import all required libraries
import time
import grovepi

lightSensorPort = 0 # number of analog port the light sensor connect to

# while True:
    # try:
lightIntensity = grovepi.analogRead(lightSensorPort)
observation = str(lightIntensity)
currentTime = time.strftime("%Y-%m-%dT%H:%M:%S.000Z",time.gmtime())
datastreamID = 1063643    # change the datastream ID as required
# part1 = 'curl -X POST -H "Content-Type: application/json" -d \''
part2 = '\'{"phenomenonTime": "'
part3 = '", "resultTime": "'
part4 = '", "result": '
part5 = ' , "Datastream": {"@iot.id": '
part6 = '}}\''
# targetUrl = "https://scratchpad.sensorup.com/OGCSensorThings/v1.0/Observations"
print(part2 + currentTime + part3 + currentTime + part4 + observation + part5 + str(datastreamID) + part6)
        # time.sleep(5)
    # except IOError:
        # print("Error")
    # except KeyboardInterrupt:
        # exit()
