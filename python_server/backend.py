import json
import paho.mqtt.client as mqtt

def on_message(client, userdata, msg):
  payload = json.loads(msg.payload)

  print(f'Latitude: {payload["latitude"]}')
  print(f'Longitude: {payload["longitude"]}')

client = mqtt.Client()
client.on_message = on_message

client.connect('localhost', 1883)

client.subscribe('my-location')

client.loop_forever()