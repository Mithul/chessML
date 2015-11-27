count = 0
arr = []
a = []
10.times do |i|
   arr[i] = Thread.new {
      sleep(rand(0)/10.0)
      # Thread.current["mycount"] = count
      a << count
      count += 1
      sleep (rand(10)+1)/10
   }
end

# arr.each {|t| t.join; print t["mycount"], ", " }
arr.each {|t| t.join; }
puts "count = #{count}"
puts a.to_s