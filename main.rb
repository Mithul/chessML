require_relative 'Horse'
require_relative 'Pawn'
require_relative 'King'
require_relative 'tile'
require_relative 'utils/probability_picker'

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

pieces = []
x=1
y=1
pieces << Horse.new(x,y,board,'white')
board[x][y].set_piece pieces.last
x=2
(1..8).each do |y|
	pieces << Pawn.new(x,y,board,'white')
end
puts pieces.map{|p| p.class}.join(', ')
board[x][y].set_piece pieces.last
horse1 = Horse.new x,y,board,'black'
board[2][4].set_piece horse1
king = King.new x,y,board,'black'
board[8][8].set_piece king
# puts horse
# 8.times do
	# Thread.new{
		1000.times do
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
				# puts moves[p[0]].to_s
			end
			# puts piece_type_prob.to_s
			p = picker piece_type_prob
			# puts p.to_s
			old_pos = pieces[p[2][0]].position?
			change = pieces[p[2][0]].move moves[p[2][0]][p[2][1]]
			pos = pieces[p[2][0]].position?
			piece_type = pieces[p[2][0]].class.to_s
			if change == true
				puts 'Win'
				exit
			elsif change
				pieces.delete_at p[2][0]
				pieces << change
			end
			puts piece_type+' moved from '+old_pos.to_s+' to '+ pos.to_s
			if change
				puts 'Changed to '+change.class.to_s
			end
		end
	# }
# end