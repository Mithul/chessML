require_relative 'Piece'

class Pawn < Piece
	def initialize x,y,board,color
		super x,y,board,color,2
		@moved = false
	end

	def check_possible_moves
		@possible_moves = []
		if @alive
			if @color == 'black'
				advance = -1
			else
				advance = 1
			end
			if @x+advance<=8 and @x+advance>0
				if @board[@x+advance][@y].piece == nil
					move = [@x+advance,@y,1]
					@possible_moves << move
				end

				if !@moved and ((@x==2 and advance==1) or (@x==7 and advance==-1)) and @board[@x+2*advance][@y].piece == nil and @board[@x+advance][@y].piece == nil
					move = [@x+2*advance,@y,2]
					@possible_moves << move
					@moved = true
				end

				if @y+1<=8 and @board[@x+advance][@y+1].piece and @board[@x+advance][@y+1].piece.color != @color
					move = [@x+advance,@y+1,@board[@x+advance][@y+1].piece.value]
					@possible_moves << move
				end

				if @y-1>0 and @board[@x+advance][@y-1].piece and @board[@x+advance][@y-1].piece.color != @color
					move = [@x+advance,@y-1,@board[@x+advance][@y-1].piece.value]
					@possible_moves << move
				end
			end
		end
		@possible_moves
	end

	def move move
		if super(move) == true
			return true
		end
		if @x==8 or @x==1
			puts 'Changing pawn'
			return piece = Queen.new(@x,@y,@board,@color)
		end
		if @color == 'black'
			@value = 2+(7-@x)*8
		else
			@value = 2+(@x-2)*8
		end
		return false
	end
end