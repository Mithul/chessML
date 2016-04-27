class Player
	def initialize color, board, pieces, king, gui = nil, old_boards = []
		@color = color
		@board = board
		@pieces = pieces
		@gui = gui 
		@old_boards = old_boards
		@king = king
		@boards = []
		# @cmove = 0
	end

	def make_move piece, move
		old_pos = piece.position?
		change = piece.move move
		pos = piece.position?
		piece_type = piece.class.to_s
		piece_color = piece.color.to_s
		puts piece_color+ ' ' + piece_type+' moved from '+old_pos.to_s+' to '+ pos.to_s
		move = old_pos.to_s+':'+pos.to_s
		return move,change
	end

	def play
		pieces = @pieces
		board = @board
		gui = @gui
		old_boards = @old_boards
		boards = @boards
		# cmove = @cmove
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
		piece_type_prob = piece_type_prob.uniq
		piece_type_prob.delete(nil)
		# puts piece_type_prob.to_s
		if piece_type_prob[0] == nil
			puts 'Cannot move'
			sleep(6)
			cmove = cmove + 1
			if cmove == 2
				return
			end
			return
		else
			cmove = 0
		end
		# puts p.to_s

		current_board = {board: Marshal.load(Marshal.dump(board)).dup, move: nil}
		# sleep 2
		# current_board = boards[-1]
		cboard = compress_board current_board[:board]
		gui.draw cboard if gui
		# puts 'c '+cboard.join.to_s
		# puts 'o '+old_boards.first.to_s
		# cboard = old_boards.first.dup
		# index = old_boards.index(cboard.join)
		indeces = old_boards.each_index.select{|i| old_boards[i] == cboard.join}
		# puts indeces.to_s


		# TODO
		checked = false
		puts @color

		checked = @king.under_check? @pieces.select{|b| b.alive}
		king = @king
				
		if checked
			make_move king, checked
			return
		end

		max = 0
		best_index = nil
		indeces.each do |index|
			if @old_boards[index][@color] > max
				max = @old_boards[index][@color]
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
		move = moves[p[2][0]][p[2][1]]
		# puts move.to_s
		# puts p[2][0].to_s
		# puts pieces[p[2][0]].to_s
		move, change = make_move pieces[p[2][0]], move

		current_board[:move] = move
		boards << current_board
		# print_board board
		# if turn == 0
		# 	exit
		# end

		if change == true
			statistics = []
			if @color=='white'
				winner = 'white'
				loser = 'black'
			else
				winner = 'black'
				loser = 'white'
			end

			# @mutex.synchronize do
			# @old_boards = read_file @file
			# puts @old_boards.to_s
			boards.each do |board|
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
			gui.used = false if gui
			return change
			# exit
		elsif change
			pieces.delete_at p[2][0]
			pieces << change
		end
		if change
			puts 'Changed to '+change.class.to_s
		end
		# @cmove = cmove
	end

	def get_statistics
		return @old_boards
	end
end