import time
import sys
import paho.mqtt.client as mqtt
import machine_pb2

def on_connect(client, userdata, flags, rc):
    print("Connected with result code "+str(rc))
    # Subscribing in on_connect() means that if we lose the connection and
    # reconnect then subscriptions will be renewed.
    client.subscribe(f"/{org}/{site}/{session}/#")

# The callback for when a PUBLISH message is received from the server.
def on_message(client, userdata, msg):
    print(msg.topic)


org = "Organization"
site = "JobSite"
session = "Session"

startLat = 42.567680
startLon = -90.688962

numberOfMachines = 3
machineNames = [f"mach{x}" for x in range(numberOfMachines)]
machineInfo = [machine_pb2.VehicleInfo() for x in range(numberOfMachines)]
for i, veh in enumerate(machineInfo):
    veh.location.latitude = startLat + i * 0.001
    veh.location.longitude = startLon + i * 0.001
    if i % 2:
        veh.model.model_name = "truck"
    else:
        veh.model.model_name = "airplane"

client = mqtt.Client()
client.on_connect = on_connect
client.on_message = on_message

client.connect("test.mosquitto.org", 1883, 60)

# Blocking call that processes network traffic, dispatches callbacks and
# handles reconnecting.
# Other loop*() functions are available that give a threaded interface and a
# manual interface.
#client.loop_forever()
client.loop_start()

steps = 20
i = 0
while True:
    time.sleep(0.5)

    for machName, veh in zip(machineNames, machineInfo):

        if i < steps:
            veh.location.latitude += 0.0001
            veh.location.longitude += 0.0001
        elif i < steps*2:
            veh.location.latitude -= 0.0001
            veh.location.longitude += 0.0001
        elif i < steps*3:
            veh.location.latitude -= 0.0001
            veh.location.longitude -= 0.0001
        elif i < steps*4:
            veh.location.latitude += 0.0001
            veh.location.longitude -= 0.0001
        else:
            i = 0
        payload = veh.SerializeToString()
        print(i)
        client.publish(f"{org}/{site}/{session}/{machName}", payload)
    i += 1

client.loop_stop()