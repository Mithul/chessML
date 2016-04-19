require_relative 'Piece'

class King < Piece
	def initialize x,y,board,color
		super x,y,board,color,100000
	end

	def check_possible_moves
		@possible_moves = []
		if @alive
			possible_moves = [[@x+1,@y+1],[@x-1,@y+1],[@x+1,@y-1],[@x-1,@y-1],[@x-1,@y],[@x+1,@y],[@x,@y-1],[@x,@y+1]]
			possible_moves.each do |move|
				if move[0]>0 and move[1]>0 and move[0]<=8 and move[1]<=8
					# puts 'debug '+move.to_s
					if @board[move[0]][move[1]].piece == nil or @board[move[0]][move[1]].piece.color != @color
						if @board[move[0]][move[1]].piece
							move[2] = @board[move[0]][move[1]].piece.value
						else
							move[2] = 1
						end
						@possible_moves << move
					end
				end
			end
		end
		@possible_moves
	end

	def get_board
		@board
	end

	def under_check? opponent_pieces, pieces, player
		old_cboard = player.compress_board @board
		checked_places = []
		causer = true
		completed_pieces = []
		completed_moves = {}
		move = nil
		piece = nil
		old_pos = nil
		checked = check? opponent_pieces
		while checked
			if piece and move and old_pos
				player.make_move piece, old_pos
			end
			causer = nil
			piece = (pieces - completed_pieces)[0]
			if !piece
				return true, nil
			end
			i = pieces.index piece
			completed_moves[i] = [] if !completed_moves[i]
			move = (piece.check_possible_moves - completed_moves[i])[0]
			if move
				old_pos = piece.position?
				player.make_move piece, move
				completed_moves[i] << move
			else
				completed_pieces << piece
			end
			# pieces.each_with_index do |piece,i|
			# 	moves = piece.check_possible_moves
			# 	moves.each do |move|
			# 		player.make_move piece, move
			# 		puts 'made move'
			# 	end
			# end
			checked = check? opponent_pieces
			@board = player.decompress_board old_cboard if checked
		end
		return piece, move
	end

	def move move
		x=@x
		y=@y
		super move
		# check? [@x,@y]
	end

	private 
	def check? opponent_pieces
		opponent_pieces.each do |piece|
			# puts piece.class.to_s + ' ' + piece.color + ' ' + piece.check_possible_moves.map{|p| [p[0],p[1]]}.to_s
			# checked_places << piece.check_possible_moves.map{|p| [p[0],p[1],1000]}
			if piece.check_possible_moves.map{|p| [p[0],p[1]]}.include? self.position?
				# puts "Im under a CHECK!!!"
				# causer = piece
				# break
				return true
			end
		end
		return false
	end
end