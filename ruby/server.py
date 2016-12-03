import socket
import json
import time

serversocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
serversocket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

serversocket.bind(("0.0.0.0", 5555))
serversocket.listen(0)

EXIT=0
LEARN=1

def send(msg, status, socket):
	x=json.dumps(msg)
	x = str(len(x)).zfill(8) + x
	socket.send(x)
	return True

def recv(socket):
	msg = socket.recv(8)
	length = int(msg)
	msg = socket.recv(length)
	msg = json.loads(msg)
	# msg = msg.split[0]
	return msg

while 1:
	#accept connections from outside
	(clientsocket, address) = serversocket.accept()
	#now do something with the clientsocket
	#in this case, we'll pretend this is a threaded server
	while 1:
		# print send([1,2,3],clientsocket)
		x = recv(clientsocket)
		print x
		if x['status'] == EXIT:
			exit()
