def picker(options)
	if options.class == Hash
	  current, max = 0, options.values.inject(:+)
	  random_value = rand(max) + 1
	  options.each do |key,val|
	     current += val
	     return key if random_value <= current
	  end
	elsif options.class == Array
		# puts options.to_s
		options = options.compact
		probabilities = options.map{|o| o[2]}
		# puts probabilities.to_s
		maximum = probabilities.max
		current, max = 0, probabilities.inject(:+)
		random_value = rand(max) + 1
	  	options.each_with_index do |val,key|
	     current += val[2]
	     return [key,maximum,val] if random_value <= current
	  	end
	end
end