require_relative 'Piece'

class King < Piece
	def initialize x,y,board,color
		super x,y,board,color,100
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

	def move move
		x=@x
		y=@y
		super move
		# check? [@x,@y]
	end
end