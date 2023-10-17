from flask import Flask, json, request, jsonify, send_file
from flask_cors import CORS
import time
from multiprocessing import Process

# tebe3 serverur socket
import socket
import json


import requests


app = Flask(__name__)
CORS(app)

hostSocket1 = "0.0.0.0"  # Listen on all available network interfaces
portSocket1 = 65433

hostSocket2 = "0.0.0.0"  # Listen on all available network interfaces
portSocket2 = 65432

# Define the host and port of the server
senderId1= 1
senderIp1 = '192.168.112.151'  # Replace with the server's IP address
senderPort1 = 65433

# Define the host and port of the server
senderId2= 2
senderIp2 = '192.168.112.104'  # Replace with the server's IP address
senderPort2 = 65432


global position_data
position_data = [{
    "ipAdress": "102.173.45.228",
    "content": { "latitude": 35.8245029, "longitude": 11.634584 },
    "timestamp": 1697573215.0618484
  },{
    "ipAdress": "102.173.45.229",
    "content": { "latitude": 35.8245029, "longitude": 12.634584 },
    "timestamp": 1697573215.0618484
  },{
    "ipAdress": "102.173.45.230",
    "content": { "latitude": 35.8245029, "longitude": 13.634584 },
    "timestamp": 1697573215.0618484
  }]
ipAdress = []


# Define a function to remove the earliest element from the list every 15 seconds
def remove_oldest_data():
    while True:
        if len(position_data) > 0:
            position_data.pop(0)

        if len(ipAdress) > 0:
            ipAdress.pop(0)
        # Write the updated list to the file
        with open("position_data.json", "w") as json_file:
            json.dump(position_data, json_file)
        time.sleep(60)


def socket_send(host, port):
    
    while True:
        global position_data
        # Create a socket object
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as server_socket:
            # Bind the socket to the host and port
            server_socket.bind((host, port))

            # Start listening for incoming connections
            server_socket.listen()

            print("Server listening on", (host, port))

            # Accept a client connection
            conn, addr = server_socket.accept()
            print("Connected by", addr)

            with conn:
                # Prepare a sample JSON data to send to the client
                print(position_data)
                
                json_data = position_data


                # Serialize the JSON data to send
                json_message = json.dumps(json_data)

                # Send the JSON message to the client
                conn.sendall(json_message.encode())
        time.sleep(10)     

def socket_receive(id, host, port):
    while True:
        try:
            # Attempt to create a socket and connect to the server
            with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as client_socket:
                client_socket.settimeout(5)  # Set a timeout for the connection
                try:
                    client_socket.connect((host, port))
                except (ConnectionRefusedError, TimeoutError):
                    print("Server is not available. Retrying in 5 seconds...")
                    time.sleep(5)
                    continue  # Retry the connection

                # Receive the server's JSON message
                json_message = client_socket.recv(1024).decode()
                print("Recieved from ", id, json_message)

                # Deserialize the JSON message
                try:
                    json_data = json.loads(json_message)
                    print('Received JSON message from the server:', json_data)
                    # Write the updated list to the file
                    if id==1:
                        with open("received_position_data1.json", "w") as json_file:
                            json.dump(json_data, json_file)
                    elif id==2:
                        with open("received_position_data2.json", "w") as json_file:
                            json.dump(json_data, json_file)

                except json.JSONDecodeError as e:
                    print('Error decoding JSON message:', str(e))
        except KeyboardInterrupt:
            print("Client interrupted. Exiting...")
            break
        except Exception as e:
            print("An error occurred:", str(e))




# Start the timer thread to remove oldest data
#start_thread(remove_oldest_data)



# Start the thread to send JSON data


# flutter request
@app.route("/position", methods=["POST"])
def receive_position():
    global position_data
    data = request.get_json()
    latitude = data.get("latitude")
    longitude = data.get("longitude")
    ip_address = data.get("ipAddress")  # Get the 'ipAddress' from the JSON

    # Add a timestamp to the data
    data["timestamp"] = time.time()
    ipAdress.append(ip_address)

    # Append the updated data to the list
    position_data.append(data)

    # Write the updated list to the file
    with open("position_data.json", "w") as json_file:
        json.dump(position_data, json_file)
    print(position_data)

    # Reading JSON data from a file
    with open("received_position_data1.json", "r") as received_positions1:
        received_position_data1 = json.load(received_positions1)
    with open("received_position_data2.json", "r") as received_positions2:
        received_position_data2 = json.load(received_positions2)


    # Send the position data to the destination server via HTTP
    return jsonify(position_data + received_position_data1 + received_position_data2), 200


if __name__ == "__main__":
    # Create processes for each function
    socket_receive_process1 = Process(target=socket_receive, args=(senderId1, senderIp1,senderPort1))
    socket_receive_process2 = Process(target=socket_receive, args=(senderId2, senderIp2,senderPort2))
    socket_send_process1 = Process(target=socket_send, args=(hostSocket1, portSocket1))
    socket_send_process2 = Process(target=socket_send, args=(hostSocket2, portSocket2))
    #remove_process = Process(target=remove_oldest_data)
    # Start the processes
    socket_receive_process1.start()
    socket_receive_process2.start()
    socket_send_process1.start()
    socket_send_process2.start()
    #remove_process.start()


    # Start the Flask app in the main thread
    app.run(host=hostSocket1, port=5000)

    
    # Wait for the other processes to finish
     # Start the processes
    socket_receive_process1.start()
    socket_receive_process2.start()
    socket_send_process1.join()
    socket_send_process2.join()
    #remove_process.join()