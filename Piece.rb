# require_relative 'King'

class Piece 
	attr_accessor :color,:alive,:value
	def initialize x,y,board,color,value
		@x=x
		@y=y
		@alive=true
		@board = board
		@color = color
		@value = value
	end

	def move move
			@board[@x][@y].set_piece nil
			@x=move[0]
			@y=move[1]
		if @board[move[0]][move[1]].piece and @board[move[0]][move[1]].piece.color != @color
			

			piece = @board[move[0]][move[1]].piece
			puts piece.color.to_s.capitalize+' '+piece.class.to_s+' Killed'
			piece.alive = false
			@board[move[0]][move[1]].set_piece nil
			if piece.class.to_s == 'King'
				puts 'Game Over'
				return true
			end
		end
		@board[@x][@y].set_piece self
		return nil
	end


	def position?
		return [@x,@y]
	end

end