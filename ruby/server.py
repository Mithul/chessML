import socket
import json
import time
import tensorflow as tf
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

class Bot:
	def __init__(self, name):
		self.name = name
	def setup_nn(self):
		input_size = 8*8*6*2
		layers = [512, 512]
		output_size = (8*8)**2
		self.nnet = {}
		with tf.variable_scope('bot_'+self.name):
			input = tf.placeholder(tf.float32, shape=[None,input_size], name="input")
			self.nnet['input'] = input
			score = tf.placeholder(tf.float32,shape=[None,output_size], name="score")
			self.nnet['score'] = score
			prev_input = input
			for i, size in enumerate(layers):
				w = tf.Variable(tf.random_uniform([input_size,size]), name="hidden_w_"+str(i))
				self.nnet["hidden_w_"+str(i)] = w
				b = tf.Variable(tf.random_uniform([size]), name="hidden_b_"+str(i))
				self.nnet["hidden_b_"+str(i)] = b
				output = tf.sigmoid(tf.matmul(prev_input,w)+b)
				self.nnet["output_"+str(i)] = output
				prev_input = output
				input_size = size
			
			ws = tf.Variable(tf.zeros([input_size,output_size]))
			self.nnet["hidden_ws"] = ws
			bs = tf.Variable(tf.zeros([output_size]))
			self.nnet["hidden_bs"] = bs
			pred = tf.nn.softmax(tf.matmul(output,ws)+bs)
			self.nnet["output_pred"] = pred
			optimizer = tf.train.AdagradOptimizer(0.1)

			loss_m = tf.reduce_mean(-tf.reduce_sum(score * tf.log(tf.maximum(pred,pred + 1e-10)), reduction_indices=[1]))
			train_step = optimizer.minimize(loss_m)

			self.op1 = output
			self.thrusters = pred
			self.train_step = train_step
			self.loss = loss_m
			self.input_nn = input
			self.score = score
			self.final = pred 

sess = tf.Session()

bot = Bot('first')
bot.setup_nn()
init = tf.initialize_all_variables()
sess.run(init)

while 1:
	#accept connections from outside
	(clientsocket, address) = serversocket.accept()
	#now do something with the clientsocket
	#in this case, we'll pretend this is a threaded server
	while 1:
		# print send([1,2,3],clientsocket)
		x = recv(clientsocket)
		print x
		if x['status'] == LEARN:
			z = sess.run(bot.nnet["output_pred"], {bot.input_nn: x["data"]})
			print z
			exit()
		if x['status'] == EXIT:
			exit()
