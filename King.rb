require_relative 'Piece'

class King < Piece
	def initialize x,y,board,color
		super x,y,board,color
	end

	def check_possible_moves
		@possible_moves = []
		if @alive
			possible_moves = [[@x+3,@y+1],[@x-3,@y+1],[@x+3,@y-1],[@x-3,@y-1], [@x+1,@y+3],[@x-1,@y+3],[@x+1,@y-3],[@x-1,@y-3]]
			possible_moves.each do |move|
				if move[0]>0 and move[1]>0 and move[0]<=8 and move[1]<=8
					# puts 'debug '+move.to_s
					if @board[move[0]][move[1]].piece == nil or @board[move[0]][move[1]].piece.color != @color
						if @board[move[0]][move[1]].piece
							move[2] = 5
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
end