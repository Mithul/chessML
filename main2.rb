require_relative 'Horse'
require_relative 'Pawn'
require_relative 'King'
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
			end
			board[i/8+1][i%8+1].set_piece piece
		end
	end
	# print_board board
	# puts board.to_s
end

# {cboard: "positions", boards: [{move: , cboard: "", white: , black: , boards: []},{}]}

def run
	boards = {}
	cmove=0
	# old_boards = @old_boards.map{|o| o[:board].join}
	# current_board = @old_boards[:board]
	s_board = @old_boards[:board] if !@old_boards.empty?
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

	(1..8).each do |y|
		white_pieces << Pawn.new(2,y,board,'white')
		board[2][y].set_piece white_pieces.last
		black_pieces << Pawn.new(7,y,board,'black')
		board[7][y].set_piece black_pieces.last
	end
	# puts 	pieces.map{|p| p.class}.join(', ')
	# board[x][y].set_piece pieces.last
	black_pieces << King.new(8,4,board,'black')
	board[8][4].set_piece black_pieces.last
	white_pieces << King.new(1,4,board,'white')
	board[1][4].set_piece white_pieces.last

	boards[:board] = board
	boards[:boards] = []
	# puts horse
	# 8.times do
	# Thread.new{
	100000.times do |turn|
		if turn%2==0
			current_turn_color = "white"
			pieces = white_pieces
		else
			current_turn_color = "black"
			pieces = black_pieces
		end
		moves = []
		piece_type_prob = []
		pieces.each_with_index do |piece,i|
			moves[i] = piece.check_possible_moves
			# puts i.to_s + ' ' + moves[i].to_s
			if moves[i][0] != nil
				p = picker moves[i] 
				piece_type_prob[i] = [i,p[0],p[1]]
			end
			# puts 'prob '+piece_type_prob[i].to_s
			# puts moves[i].to_s
		end
		# puts pieces.map{|p| p.class if p.alive}.join(', ')
		# puts piece_type_prob.to_s
		if piece_type_prob[0] == nil
			# puts 'Cannot move'
			cmove = cmove + 1
			if cmove == 2
				return
			end
			next
		else
			cmove = 0
		end
		# puts p.to_s

		current_board = {board: Marshal.load(Marshal.dump(board)).dup, move: nil, white: nil, black: nil, boards: []}

		cboard = compress_board current_board[:board]
		# indeces = board[:boards].each_index.select{|i| old_boards[i] == cboard.join}
		max = 0
		best_index = nil
		possible_boards = []
		possible_boards = s_board[:boards] if s_board
		possible_boards.each_with_index do |board1,index|
			if board1[current_turn_color] > max
				max = board1[current_turn_color]
				best_index = index
			end
		end

		if best_index
			# puts 'f '+old_boards[index].to_s
			# puts 'f '+@old_boards[index].to_s


			best_board = @old_boards[best_index]
			suggested_move = best_board[:move]

			from = eval suggested_move.split(':')[0]
			to = eval suggested_move.split(':')[1]
			# puts from.to_s
			# puts to.to_s
			piece = board[from[0]][from[1]].piece
			piece_index = pieces.index(piece)
			if piece_index
				# puts piece_index
				to[2] = best_board[current_turn_color]
				moves[piece_index] << to
				p = picker moves[piece_index] 
				piece_type_prob[piece_index] = [piece_index,p[0],p[1]]
				# puts current_turn_color + ' ' + to[2].to_s
			end
			# puts 'FOUND'
			# puts index
			# sleep 1
			# exit 
		end

		p = picker piece_type_prob

		old_pos = pieces[p[2][0]].position?
		change = pieces[p[2][0]].move moves[p[2][0]][p[2][1]]
		pos = pieces[p[2][0]].position?
		piece_type = pieces[p[2][0]].class.to_s
		piece_color = pieces[p[2][0]].color.to_s
		# puts piece_color+ ' ' + piece_type+' moved from '+old_pos.to_s+' to '+ pos.to_s
		move = old_pos.to_s+':'+pos.to_s

		current_board[:move] = move
		boards[:boards] << current_board
		# print_board board
		# if turn == 0
		# 	exit
		# end

		if change == true
			statistics = []
			if turn%2==0
				winner = 'white'
				loser = 'black'
			else
				winner = 'black'
				loser = 'white'
			end

			# @mutex.synchronize do
			# @old_boards = read_file @file
			boards.select{|board| board[:boards]}.each do |board|
				puts '*'*100
				puts board.to_s
				cboard = compress_board board[:board]
				index = @old_boards.index(cboard.join)
				indeces = []
				@old_boards.each_index do |i| 
					if @old_boards[i][:board] == cboard and @old_boards[i][:move] == board[:move]
						indeces << i
						break
					end
				end

				if indeces[0]
					index = indeces[0]
					@old_boards[index][winner] = @old_boards[index][winner] + 10
					@old_boards[index][loser] = @old_boards[index][loser] - 5
					# puts ({board: cboard, winner => 10, loser => 5,move: board[:move]}).to_s
					# puts @old_boards[index]
					# exit
				else
					statistics << {board: cboard, winner => 10, loser => 5,move: board[:move]}
				end
			end
			statistics = @old_boards + statistics
			@old_boards = statistics

			# end

			# puts 'Win'
			puts @count
			# puts king1.position?.to_s
			return
			# exit
		elsif change
			pieces.delete_at p[2][0]
			pieces << change
		end
		if change
			# puts 'Changed to '+change.class.to_s
		end
	end
	# }
	# end

end

@file = "statistics_new.dat"

@mutex = Mutex.new
@old_boards = read_file @file

t= []
threads = 1
iterations = 3
threads.times do |i|
	t[i] = Thread.new{
		iterations.times do |iter|
			begin
				# @old_boards = read_file @file
				# puts @old_boards
				# decompress_board @old_boards.first
				run
			rescue SystemExit, Interrupt
				f = File.open(@file,"w")
				f.write @old_boards
				f.close
				raise
			end
		end
	}
end
threads.times do |i|
	t[i].join
end
# if iter%5 == 0 and iter !=0
puts "Writing"
f = File.open(@file,"w")
f.write @old_boards
f.close
puts "Done"
# end

