import socket
import json
import time
import tensorflow as tf
import numpy as np
serversocket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
serversocket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

serversocket.bind(("0.0.0.0", 5555))
serversocket.listen(0)

EXIT=0
LEARN=1
ACK=2
PRED=3
RESULT=4
ERROR=-1

def send(msg, status, socket, extra=None):
	msg = {"status": status, "data": msg, "extra": extra}
	x=json.dumps(msg)
	x = str(len(x)).zfill(8) + x
	socket.send(x)
	return True

def recv(socket):
	msg = {'status': ERROR }
	try:
		msg = socket.recv(8)
		length = int(msg)
		msg = socket.recv(length)
		msg = json.loads(msg)
		# print "sending"
		# send([],ACK, socket)
	except:
		msg = {'status': ERROR }
		# print "sendinge"
		# send([],ERROR, socket)
		# msg = msg.split[0]
	return msg

class Bot:
	def __init__(self, name):
		self.name = name
	def setup_nn(self):
		input_size = 8*8*6*2
		layers = [256]*5
		output_size = (8*8)**2
		self.nnet = {}
		with tf.variable_scope('bot_'+self.name):
			input = tf.placeholder(tf.float32, shape=[None,input_size], name="input")
			self.nnet['input'] = input
			score = tf.placeholder(tf.float32,shape=[None, output_size], name="score")
			self.nnet['score'] = score
			prev_input = input
			for i, size in enumerate(layers):
				w = tf.Variable(tf.random_normal([input_size,size]), name="hidden_w_"+str(i))
				self.nnet["hidden_w_"+str(i)] = w
				b = tf.Variable(tf.random_normal([size]), name="hidden_b_"+str(i))
				self.nnet["hidden_b_"+str(i)] = b
				output = tf.nn.dropout(tf.nn.relu6(tf.matmul(prev_input,w)+b), 0.2)
				self.nnet["output_"+str(i)] = output
				prev_input = output
				input_size = size
			
			ws = tf.Variable(tf.zeros([input_size,output_size]))
			self.nnet["hidden_ws"] = ws
			bs = tf.Variable(tf.zeros([output_size]))
			self.nnet["hidden_bs"] = bs
			# pred = tf.nn.softmax(tf.matmul(output,ws)+bs)
			optimizer = tf.train.AdagradOptimizer(0.001)
			loss_m = []
			train_step = []
			op = None
			# print output.get_shape(), score.get_shape()
			# cross_entropy = tf.nn.sparse_softmax_cross_entropy_with_logits(tf.maximum(output,output + 1e-10), score, name='xentropy')
			# loss_m = tf.reduce_mean(cross_entropy, name='xentropy_mean')
			# loss_m = tf.reduce_mean(-tf.reduce_sum(score * tf.log(tf.maximum(pred,pred + 1e-10)), reduction_indices=[1]))
			# train_step = optimizer.minimize(loss_m)
			for i, size in enumerate(layers):
				op = tf.nn.softmax(tf.matmul(self.nnet["output_"+str(i)],ws)+bs)
				loss_m.append(tf.reduce_mean(-tf.reduce_sum(score * tf.log(tf.maximum(op,op + 1e-10)), reduction_indices=[1])))
				train_step.append(optimizer.minimize(loss_m[-1]))

			pred = op
			self.nnet["output_pred"] = pred
			self.op1 = output
			self.thrusters = pred
			self.train_step = train_step
			self.loss = loss_m
			self.input_nn = input
			self.score = score
			self.final = pred 

def get_data(data, batch_size=1000):
	for i in range(len(data)/batch_size):
		if (i+1)*batch_size > len(data):
			yield [data[0][i*batch_size:], data[1][i*batch_size:]]
		else:
			yield [data[0][i*batch_size: (i+1)*batch_size], data[1][i*batch_size: (i+1)*batch_size]]

sess = tf.Session()

bot = Bot('first')
bot.setup_nn()
init = tf.initialize_all_variables()
sess.run(init)
saver = tf.train.Saver()
ckpt = tf.train.get_checkpoint_state('models/')
if ckpt and ckpt.model_checkpoint_path:
	print("Checkpoint Found ")
	saver.restore(sess, ckpt.model_checkpoint_path)

glob_inp = []
glob_op = []
while 1:
	#accept connections from outside
	(clientsocket, address) = serversocket.accept()
	#now do something with the clientsocket
	#in this case, we'll pretend this is a threaded server
	step = 0
	while 1:
		# print send([1,2,3],clientsocket)
		x = recv(clientsocket)
		# print x
		if x['status'] == PRED:
			inputs = x["data"]["board"]
			print x
			z = sess.run(bot.final, {bot.input_nn: [inputs]})
			send({"move":np.argmax(z[-1]), "score":int(10*z[-1][np.argmax(z[-1])])},RESULT, clientsocket, extra=x["extra"])
		elif x['status'] == LEARN:
			inputs = []
			outputs = []
			for stat in x["data"]:
				inputs.append(stat["board"])
				glob_inp.append(stat["board"])
				op_arr = np.zeros([64*64])
				fr = eval(stat["move"].split(':')[0])
				to = eval(stat["move"].split(':')[1])
				fr[0]=fr[0]-1
				fr[1]=fr[1]-1
				to[0]=to[0]-1
				to[1]=to[1]-1
				score_w = int(stat["white"])
				score_b = int(stat["black"])
				# print fr[0]*8*8*8 + fr[1]*8*8 +to[0]*8 + to[1]
				op_arr[fr[0]*8*8*8 + fr[1]*8*8 +to[0]*8 + to[1]] = 1
				print fr[0]*8*8*8 + fr[1]*8*8 +to[0]*8 + to[1]
				outputs.append(op_arr)
				glob_op.append(op_arr)
				# _,z, h = sess.run([bot.train_step, bot.final, bot.nnet["output_0"]], {bot.input_nn: [stat["board"]], bot.score: [op_arr]})
				# print z, z.shape, z[0].shape
				# print h
				# print np.argmax(z[-1]),z[-1][np.argmax(z[-1])]
			# print outputs
			# z = sess.run(bot.nnet["output_pred"], {bot.input_nn: inputs})
			step = step + 1
			if step%1000==0:
				print "Saving model"
				saver.save(sess, 'models/' + 'model.ckpt', global_step=1)
				open('models/data','w').write(str([glob_op, glob_inp]))
				data_it = get_data([glob_op,glob_inp])
				for data in data_it:
					[sess.run(bot.train_step[-1], {bot.input_nn: glob_inp, bot.score: glob_op}) for i in range(1)]

				# [sess.run(bot.train_step[-1], {bot.input_nn: glob_inp, bot.score: glob_op}) for i in range(1)]
			[sess.run(bot.train_step[-1], {bot.input_nn: inputs, bot.score: outputs}) for i in range(1)]
			loss= sess.run(bot.loss, {bot.input_nn: inputs, bot.score: outputs})
			z, h0, h3, h5 = sess.run([bot.final, bot.nnet["output_0"], bot.nnet["output_1"], bot.nnet["output_0"]], {bot.input_nn: inputs, bot.score: outputs})
			print 'final ',z, z.shape, z[0].shape
			print 'loss ',loss
			print 'hidden ',h0,h3,h5
			print 'top ',np.argmax(z[-1]),np.argpartition(z[-1],-5)[-5:],z[-1][np.argpartition(z[-1],-5)[-5:]]
			# print 'top ',np.argmax(z[-2]),np.argpartition(z[-2],-5)[-5:],z[-2][np.argpartition(z[-2],-5)[-5:]]
		if x['status'] == EXIT:
			saver.save(sess, 'models/' + 'model.ckpt', global_step=1)
			exit()
