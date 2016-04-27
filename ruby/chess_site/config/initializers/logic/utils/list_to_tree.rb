def read_file file
	boards = nil
	begin
		f = File.open(file,"r")
		text = f.read
		boards = eval text
	rescue
	end
	if boards == nil
		boards = []
	end
	return boards
end

# @file = "statistics3.dat"
# puts "Reading"
# @boards = read_file @file
# puts "Read"
# @new_board = {@boards.first => []}
# @boards.each_with_index do |board,c|
# 	indeces = @boards.each_index.select{|i| @boards[i] == board && c!=i}
# 	if !indeces.empty?
# 		puts indeces.to_s 
# 		# puts @boards[indeces.first]
# 		boards = {@boards[indeces.first] => []}
# 		puts boards.to_s
# 	end 
# end
