import socket
import json
import time

serversocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
serversocket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

serversocket.bind(("0.0.0.0", 5555))
serversocket.listen(0)

def send(msg, socket):
	x=json.dumps(msg)
	x = str(len(x)).zfill(4) + x + ':'
	socket.send(x)
	return True

def recv(socket):
	msg = socket.recv(1024)
	length = msg[0:4]
	msg = msg.split(':')[0][4:]
	return msg

while 1:
	#accept connections from outside
	(clientsocket, address) = serversocket.accept()
	#now do something with the clientsocket
	#in this case, we'll pretend this is a threaded server
	while 1:
		send([1,2,3], clientsocket)
		print recv(clientsocket)