require 'socket'
require 'json'

streamSock = TCPSocket.new( "127.0.0.1", 5555 )

class NN
	def initialize(socket)
		@socket = socket
		@LEARN = 1
		@EXIT = 0
	end

	def recv
		str = @socket.recv(8)
		length = str.to_i
		str = @socket.recv(length)
		msg = str
		return JSON.parse(msg)
	end

	def send(msg, status)
		msg = {'status' => status, "data" => msg}
		msg = JSON.dump(msg)
		length = msg.to_s.length
		puts '#'*100,length
		msg = length.to_s.rjust(8, "0") + msg
		str = @socket.write(msg)
	end

	def get_move(current_board)
		from = [1,1]
		to = [2,2]
		score = 5
		return from.to_s + ':' + to.to_s + ':' + score.to_s
	end

	def learn(statistics)
		status = @LEARN
		boards = self.format_board statistics.first
		puts '+'*100 ,boards.to_s
		self.send([boards], status)
	end

	#Board dimensions color, class, x, y
	def format_board old_board
		board = []
		positions = old_board[:board]
		puts positions.to_s
		(0..5).each do |piece|
			(0..1).each do |color|
				(0..7).each do |x|
					(0..7).each do |y|
						board[6*8*8*color + 8*8*piece + 8*x+y] = 0
					end
				end
			end
		end
		positions.each_with_index do |tile,i|
			if tile != '-'
				parts = tile.split('_')
				color = 0 if parts[0]=='W'
				color = 1 if parts[0]=='B'
				x = i/8
				y = i%8
				if parts[1] == 'H'
					piece = 0
				elsif parts[1] == 'P'
					piece = 1
				elsif parts[1] == 'K'
					piece = 2
				elsif parts[1] == 'Q'
					piece = 3
				elsif parts[1] == 'R'
					piece = 4
				elsif parts[1] == 'B'
					piece = 5
				end
				board[6*8*8*color + 8*8*piece + 8*x+y] = 1
			end
		end
		return board
	end

	def quit()
		self.send(nil, @EXIT)
	end
end

@nn = NN.new streamSock

# while true
# 	puts @nn.recv().to_s
# 	msg = [4,5,6]
# 	@nn.send(msg, status)
# 	sleep 1
# end
# streamSock.close  

# exit

require_relative 'Horse'
require_relative 'Gui'
require_relative 'Pawn'
require_relative 'King'
require_relative 'Bishop'
require_relative 'Queen'
require_relative 'Rook'
require_relative 'PlayerNN'
require_relative 'tile'
require_relative 'utils/probability_picker'

@count = 0 

def print_board board
	(1..8).each do |i|
		(1..8).each do |j|
			piece = board[i][j].piece
			if piece and piece.alive
				print piece.color[0].capitalize+'_'+piece.class.to_s[0]
			else
				print '-'
			end
			print "\t"
		end
		# puts
	end
end

def compress_board board
	compressed_board = []
	(1..8).each do |i|
		(1..8).each do |j|
			piece = board[i][j].piece
			if piece and piece.alive
				compressed_board << piece.color[0].capitalize+'_'+piece.class.to_s[0]
			else
				compressed_board << '-'
			end
		end
	end
	return compressed_board
end

def read_file file
	boards = nil
	begin
		f = File.open(file,"r")
		text = f.read
		require 'zlib'
		text = Zlib::Inflate.inflate(text)
		boards = eval text
	rescue
	end
	if boards == nil
		boards = []
	end
	return boards
end

def decompress_board cboard
	board = []
	positions = cboard[:board]
	k=0
	positions.each_with_index do |tile,i|
		if i%8==0
			board[i/8+1] = []
		end
		board[i/8+1][i%8+1] = Tile.new
		if tile != '-'
			parts = tile.split('_')
			color = "white" if parts[0]=='W'
			color = "black" if parts[0]=='B'
			if parts[1] == 'H'
				piece = Horse.new i/8+1,i%8+1,board,color
			elsif parts[1] == 'P'
				piece = Pawn.new i/8+1,i%8+1,board,color
			elsif parts[1] == 'K'
				piece = King.new i/8+1,i%8+1,board,color
			elsif parts[1] == 'Q'
				piece = Queen.new i/8+1,i%8+1,board,color
			elsif parts[1] == 'R'
				piece = Rook.new i/8+1,i%8+1,board,color
			elsif parts[1] == 'B'
				piece = Bishop.new i/8+1,i%8+1,board,color
			end
			board[i/8+1][i%8+1].set_piece piece
		end
	end
	# print_board board
	# puts board.to_s
end


def run
	boards = []
	cmove=0
	old_boards = @old_boards.map{|o| o[:board].join}

	if @count==1
		# exit
	end
	@count = @count+1
	board = []

	(1..8).each do |i|
		(1..8).each do |j|
			if(j==1)
				board[i]=[]
			end
			board[i][j] = Tile.new
		end
	end

	# puts board.to_s

	white_pieces = []
	black_pieces = []

	white_pieces << Horse.new(1,2,board,'white')
	board[1][2].set_piece white_pieces.last
	black_pieces << Horse.new(8,2,board,'black')
	board[8][2].set_piece black_pieces.last

	white_pieces << Horse.new(1,7,board,'white')
	board[1][7].set_piece white_pieces.last
	black_pieces << Horse.new(8,7,board,'black')
	board[8][7].set_piece black_pieces.last

	white_pieces << Bishop.new(1,3,board,'white')
	board[1][3].set_piece white_pieces.last
	black_pieces << Bishop.new(8,3,board,'black')
	board[8][3].set_piece black_pieces.last

	white_pieces << Bishop.new(1,6,board,'white')
	board[1][6].set_piece white_pieces.last
	black_pieces << Bishop.new(8,6,board,'black')
	board[8][6].set_piece black_pieces.last

	white_pieces << Rook.new(1,1,board,'white')
	board[1][1].set_piece white_pieces.last
	black_pieces << Rook.new(8,1,board,'black')
	board[8][1].set_piece black_pieces.last

	white_pieces << Rook.new(1,8,board,'white')
	board[1][8].set_piece white_pieces.last
	black_pieces << Rook.new(8,8,board,'black')
	board[8][8].set_piece black_pieces.last

	white_pieces << Queen.new(1,5,board,'white')
	board[1][5].set_piece white_pieces.last
	black_pieces << Queen.new(8,5,board,'black')
	board[8][5].set_piece black_pieces.last

	(1..8).each do |y|
		white_pieces << Pawn.new(2,y,board,'white')
		board[2][y].set_piece white_pieces.last
		black_pieces << Pawn.new(7,y,board,'black')
		board[7][y].set_piece black_pieces.last
	end
	# puts 	pieces.map{|p| p.class}.join(', ')
	# board[x][y].set_piece pieces.last
	black_king = King.new(8,4,board,'black')
	white_king = King.new(1,4,board,'white')
	black_pieces << black_king
	board[8][4].set_piece black_pieces.last
	white_pieces << white_king
	board[1][4].set_piece white_pieces.last
	# puts horse
	# 8.times do
	# Thread.new{

	gui = @guis.select{|g| !g.used}[0]
	gui.used = true if gui

	white_player = PlayerNN.new('white',board,white_pieces, white_king, gui, @nn)
	black_player = PlayerNN.new('black',board,black_pieces, black_king, gui, @nn)

	500.times do |turn|
		puts 'turn '+turn.to_s
		if turn%2==0
			current_turn_color = "white"
			pieces = white_pieces
			player = white_player
		else
			current_turn_color = "black"
			pieces = black_pieces
			player = black_player
		end
		game = player.play
		if game == true
			@old_boards = player.get_statistics
			# sleep(5)
			return
		end
		# sleep(1)
	end
	# }
	# end

end


@mutex = Mutex.new
@old_boards = []

@guis = []
threads = 1
iterations=2
# begin
# 	require 'thread'
# 	work_q = Queue.new
# 	(0..iterations).to_a.each{|x| work_q.push x }
# 	workers = (0...threads).map do
# 		gui = Gui.new
# 		@guis << gui
# 	  Thread.new do
# 	    begin
# 	    	while x = work_q.pop(true)
# 		        run
# 			end
# 	    rescue ThreadError
# 	    end
# 	  end
# 	end; "ok"
# workers.map(&:join); "ok"
# rescue SystemExit, Interrupt
#   puts 'Error'
#   raise
# rescue StandardError
#   puts 'Error'
#   raise
# rescue Exception => e
# 	puts e
# 	puts e.backtrace
# ensure
# 	# if iter%5 == 0 and iter !=0
# 	puts "Done"
# 	# end
# end
run

@nn.quit