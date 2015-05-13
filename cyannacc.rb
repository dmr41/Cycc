

loop_init = 0
loop_total = 100000
start_time = Time.now
sequence_hash = {}
#File load
raw_file = File.open("trial.txt", "r")
file_string = raw_file.read.to_s

#word to size hash
word_size_hash = file_string.split("\n").inject(Hash.new(0)){|word, size| if(size.length >= 4); word[size] = size.length; end; word}

word_size_hash.each do |word, size|
	adjusted_size = size - 4 # change later
	letter_shift_counter = 0

	for i in 0..adjusted_size
		four_letter_key = word[letter_shift_counter..(letter_shift_counter+3)]
		if(sequence_hash[four_letter_key] == nil)
    	sequence_hash[four_letter_key] = word
		else
			sequence_hash[four_letter_key] = 0
		end

		letter_shift_counter+=1
	end
	# puts "The word #{word} is #{size} characters long."

end
puts " Sequence\tWord"
sequence_hash.each do |sequence, word|
	if(word != 0)
		puts "   #{sequence}        #{word}"
	end
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
