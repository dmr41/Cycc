
class WordAPI
	require 'open-uri'
	def initialize
		@error_counter = 0
	end
	def api_response
		open('https://s3.amazonaws.com/cyanna-it/misc/dictionary.txt').read
	end

	def user_file_response(user_file_path)
		begin
			raw_file = File.open(user_file_path, "r")
			if raw_file
				response = raw_file.read.to_s
	  	else
				raise
			end
		rescue
			@error_counter += 1
			if(@error_counter < 4)
				puts @error_counter
		  	puts "That file does not exist. Please check your path"
				puts "Please enter the correct path."
				new_user_file_path = gets.chomp
				response = user_file_response(new_user_file_path)
			else
				puts "Redirecting you to our test word list after 3 attempts."
				response = api_response
			end
		end
		response
			#
			# raw_file = File.open(user_file_path, "r")
			# raw_file.read.to_s
	end

end

puts "This program identifies all unique 4 letter sequences from a list of words"
puts "Would you like to use the 25K+ word default dictionary?(y/n): "
user_data_source_choice = gets.chomp

data_source = WordAPI.new
if(user_data_source_choice[0] == "y" || user_data_source_choice[0] == "Y")
	response = data_source.api_response
else
	puts "Please input the path to the file to be parsed: "
	file_name = gets.chomp
	response = data_source.user_file_response(file_name)
end


loop_init = 0
loop_total = 100000
start_time = Time.now
sequence_hash = {}


#word to size hash
# word_size_hash = file_string.split("\n").inject(Hash.new(0)){|word, size| if(size.length >= 4); word[size] = size.length; end; word}
word_size_hash = response.split("\n").inject(Hash.new(0)){|word, size| if(size.length >= 4); word[size] = size.length; end; word}

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

end
puts " Sequence\tWord"
File.open("sequence_list.txt", 'w') { |file| file.write("Sequence\n") }
File.open("word_list.txt", 'w') { |file| file.write("Word\n") }
sequence_hash.each do |sequence, word|
	if(word != 0)
		File.open("sequence_list.txt", 'a') { |file| file.write("#{sequence}\n") }
		File.open("word_list.txt", 'a') { |file| file.write("#{word}\n") }
		# puts "   #{sequence}        #{word}"
	end
end

stop_time = Time.now

run_time = (stop_time - start_time)
average_time = run_time/loop_total
puts "File-open total time of #{loop_total} runs: #{run_time} seconds"
puts "File-open average time: #{average_time*1000} milliseconds"
