require_relative 'logic/Horse'
require_relative 'logic/Pawn'
require_relative 'logic/King'
require_relative 'logic/Bishop'
require_relative 'logic/Queen'
require_relative 'logic/Rook'
require_relative 'logic/Player'
require_relative 'logic/tile'
require_relative 'logic/utils/probability_picker'

class BoardHandle

	def initialize
		@board = []
	end

	def html_piece piece
		if piece == 'W_R'
			return '&#9814;'
		elsif piece == 'W_K'
			return '&#9812;'
		elsif piece == 'B_K'
			return '&#9818;'
		elsif piece == 'W_Q'
			return '&#9813;'
		elsif piece == 'B_Q'
			return '&#9819;'
		elsif piece == 'W_R'
			return '&#9814;'
		elsif piece == 'B_R'
			return '&#9820;'
		elsif piece == 'W_B'
			return '&#9815;'
		elsif piece == 'B_B'
			return '&#9821;'
		elsif piece == 'W_H'
			return '&#9816;'
		elsif piece == 'B_H'
			return '&#9822;'
		elsif piece == 'W_P'
			return '&#9817;'
		elsif piece == 'B_P'
			return '&#9823;'
		end	
	end

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

	def get_piece pos
		# puts @board
		# puts @board[pos[0].to_i],pos[0]
		@board[pos[0].to_i][pos[1].to_i]
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

	def compress_board board=nil
		if board == nil
			board = @board
		end
		compressed_board = []
		# puts @board
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
			require 'zlib'
			text = Zlib::Inflate.inflate(text)
			boards = eval text
		rescue
		end
		if boards == nil
			boards = []
		end
		return boards
	end

	def set_board board
		@board = board
	end

	def get_pieces color
		return @black_pieces if color=='black'	
		return @white_pieces if color=='white'
	end

	def get_king color
		return @black_king if color=='black'	
		return @white_king if color=='white'
	end

	def decompress_board cboard
		board = []
		white_pieces = []
		black_pieces = []
		black_king=nil
		white_king=nil
		positions = cboard
		k=0
		positions.each_with_index do |tile,i|
			if i%8==0
				board[i/8+1] = []
			end
			board[i/8+1][i%8+1] = Tile.new
			if tile != '-'
				king = nil
				parts = tile.split('_')
				color = "white" if parts[0]=='W'
				color = "black" if parts[0]=='B'
				king = nil
				if parts[1] == 'H'
					piece = Horse.new i/8+1,i%8+1,board,color
				elsif parts[1] == 'P'
					piece = Pawn.new i/8+1,i%8+1,board,color
				elsif parts[1] == 'K'
					piece = King.new i/8+1,i%8+1,board,color
					king = piece
				elsif parts[1] == 'Q'
					piece = Queen.new i/8+1,i%8+1,board,color
				elsif parts[1] == 'R'
					piece = Rook.new i/8+1,i%8+1,board,color
				elsif parts[1] == 'B'
					piece = Bishop.new i/8+1,i%8+1,board,color
				end
				if color == "white"
					white_pieces << piece
					white_king = king if king
				elsif color == "black"
					black_pieces << piece
					black_king = king if king
				end
				board[i/8+1][i%8+1].set_piece piece
			end
		end
		# print_board board
		# puts board.to_s
		@board = board
		@white_pieces = white_pieces
		@black_pieces = black_pieces
		@white_king = white_king
		@black_king = black_king
		return board
	end

	def new_board
		board = @board
		(1..8).each do |i|
			(1..8).each do |j|
				if(j==1)
					board[i]=[]
				end
				board[i][j] = Tile.new
			end
		end

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

		white_pieces << Bishop.new(1,3,board,'white')
		board[1][3].set_piece white_pieces.last
		black_pieces << Bishop.new(8,3,board,'black')
		board[8][3].set_piece black_pieces.last

		white_pieces << Bishop.new(1,6,board,'white')
		board[1][6].set_piece white_pieces.last
		black_pieces << Bishop.new(8,6,board,'black')
		board[8][6].set_piece black_pieces.last

		white_pieces << Rook.new(1,1,board,'white')
		board[1][1].set_piece white_pieces.last
		black_pieces << Rook.new(8,1,board,'black')
		board[8][1].set_piece black_pieces.last

		white_pieces << Rook.new(1,8,board,'white')
		board[1][8].set_piece white_pieces.last
		black_pieces << Rook.new(8,8,board,'black')
		board[8][8].set_piece black_pieces.last

		white_pieces << Queen.new(1,5,board,'white')
		board[1][5].set_piece white_pieces.last
		black_pieces << Queen.new(8,5,board,'black')
		board[8][5].set_piece black_pieces.last

		(1..8).each do |y|
			white_pieces << Pawn.new(2,y,board,'white')
			board[2][y].set_piece white_pieces.last
			black_pieces << Pawn.new(7,y,board,'black')
			board[7][y].set_piece black_pieces.last
		end
		black_king = King.new(8,4,board,'black')
		white_king = King.new(1,4,board,'white')
		black_pieces << black_king
		board[8][4].set_piece black_pieces.last
		white_pieces << white_king
		board[1][4].set_piece white_pieces.last
		@white_pieces = white_pieces
		@black_pieces = black_pieces
		@white_king = white_king
		@black_king = black_king
	end
end