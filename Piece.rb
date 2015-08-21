# require_relative 'King'

class Piece 
	attr_accessor :color,:alive
	def initialize x,y,board,color
		@x=x
		@y=y
		@alive=true
		@board = board
		@color = color
	end

	def move move
		@x=move[0]
		@y=move[1]
		if @board[move[0]][move[1]].piece
			piece = @board[move[0]][move[1]].piece
			puts piece.color.to_s.capitalize+' '+piece.class.to_s+' Killed'
			piece.alive = false
			@board[move[0]][move[1]].set_piece nil
			if piece.class.to_s == 'King'
				puts 'Game Over'
				return true
			end
		end
	end


	def position?
		return [@x,@y]
	end

end