

loop_init = 0
loop_total = 100000
start_time = Time.now
sequence_hash = {}
#File load
raw_file = File.open("small.txt", "r")
file_string = raw_file.read.to_s

#word to size hash
word_size_hash = file_string.split("\n").inject(Hash.new(0)){|word, size| if(size.length >= 4); puts; word[size] = size.length; end; word}
word_size_hash.each do |word, size|
	puts "The word #{word} is #{size} characters long."
end

stop_time = Time.now
# puts word_size_hash
# 	counter = 0
# word_size_hash.each do |word, size|
# 	if size >0
# 		counter+=1
# 	end
# puts counter
# end
run_time = (stop_time - start_time)
average_time = run_time/loop_total
puts "File-open total time of #{loop_total} runs: #{run_time} seconds"
puts "File-open average time: #{average_time*1000} milliseconds"
