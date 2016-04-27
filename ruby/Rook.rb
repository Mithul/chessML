require_relative 'Piece'

class Rook < Piece
	def initialize x,y,board,color
		super x,y,board,color,6
	end

	def check_possible_moves
		@possible_moves = []
		if @alive
			possible_moves = []
			xy=[[1,0],[0,-1],[-1,0],[0,1]]
			(1..8).each do |i|
				# puts xy.to_s
				moves = xy.map{|m| [@x+m[0]*i,@y+m[1]*i]}
				# puts moves.to_s
				i=0
				n=moves.length
				while i<n
					if moves[i][0]>0 and moves[i][1]>0 and moves[i][0]<=8 and moves[i][1]<=8
					 	if @board[moves[i][0]][moves[i][1]].piece != nil
							xy.delete_at(i)
							if @board[moves[i][0]][moves[i][1]].piece.color == @color
								moves.delete_at(i)
								i=i-1
								n=n-1
							end
						end
					else
						xy.delete_at(i)
						moves.delete_at(i)
						i=i-1
						n=n-1
					end
					i=i+1
				end
				possible_moves = possible_moves+moves
			end
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
		# puts [@x,@y].to_s+"  "+possible_moves.to_s
		@possible_moves
	end
end