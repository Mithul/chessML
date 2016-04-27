class MLHandler
	def read_file file
		boards = nil
		begin
			f = File.open(file,"r")
			text = f.read
			require 'zlib'
			text = Zlib::Inflate.inflate(text)
			boards = eval text
		rescue Exception => e
			puts e
			puts e.backtrace
		end
		if boards == nil
			boards = []
		end
		return boards
	end

	def write_file file, boards
		puts "Writing"
		f = File.open(file,"w")
		require 'zlib'
		f.write(Zlib::Deflate.deflate(boards.to_s).force_encoding(Encoding::UTF_8))
		f.close
		puts "Done"
	end
end

::ML = MLHandler.new
$Old_boards = ::ML.read_file Rails.root.join('config/initializers','statistics.dat')

$Players = {}