require_relative 'Horse'
require_relative 'Gui'
require_relative 'Pawn'
require_relative 'King'
require_relative 'Bishop'
require_relative 'Queen'
require_relative 'Rook'
require_relative 'Player'
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

	white_player = Player.new('white',board,white_pieces, white_king, gui, @old_boards)
	black_player = Player.new('black',board,black_pieces, black_king, gui, @old_boards)

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

@file = "statistics.dat"

@mutex = Mutex.new
@old_boards = read_file @file

@guis = []

begin
	# t= []
	threads = 8
	iterations = 24
	# threads.times do |i|
	# 	gui = Gui.new
	# 	@guis << gui
	# 	t[i] = Thread.new{
	# 		iterations.times do |iter|
	# 			begin
	# 				# @old_boards = read_file @file
	# 				# puts @old_boards
	# 				# decompress_board @old_boards.first
	# 				run
	# 			rescue SystemExit, Interrupt
	# 				f = File.open(@file,"w")
	# 				f.write @old_boards
	# 				f.close
	# 				raise
	# 			end
	# 		end
	# 	}
	# end
	# threads.times do |i|
	# 	t[i].join
	# end
	# trap :INT do
	#   Thread.main.raise Interrupt
	# end
	require 'thread'
	work_q = Queue.new
	(0..iterations).to_a.each{|x| work_q.push x }
	workers = (0...threads).map do
		gui = Gui.new
		@guis << gui
	  Thread.new do
	    begin
	    	while x = work_q.pop(true)
		        run
			end
	    rescue ThreadError
	    end
	  end
	end; "ok"
workers.map(&:join); "ok"
rescue SystemExit, Interrupt
  puts 'Error'
  raise
rescue StandardError
  puts 'Error'
  raise
rescue Exception => e
	puts e
	puts e.backtrace
ensure
	# if iter%5 == 0 and iter !=0
	puts "Writing"
	f = File.open(@file,"w")
	require 'zlib'
	f.write Zlib::Deflate.deflate(@old_boards.to_s)
	f.close
	puts "Done"
	# end
end

