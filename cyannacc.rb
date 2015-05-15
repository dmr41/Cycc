
class WordAPI
	require 'open-uri'

	def initialize
		@error_counter = 0
		File.open("sequence_list.txt", 'w') { |file| file.write("Sequence\n") }
		File.open("word_list.txt", 'w') { |file| file.write("Word\n") }
	end

	def user_options
		puts "This program identifies all unique 4 letter sequences from a list of words"
		puts "Would you like to use the 25K+ word default dictionary?(y/n): "
		user_data_source_choice = gets.chomp
		if(user_data_source_choice[0] == "y" || user_data_source_choice[0] == "Y")
			response = api_response
		else
			puts "Please input the path to the file to be parsed: "
			file_name = gets.chomp
			response = user_file_response(file_name)
		end
		response
	end

	def api_response
		begin
			fetch_external_words = open('https://s3.amazonaws.com/cyanna-it/misc/dictionary.txt')
			if fetch_external_words
				response = fetch_external_words.read
			else
				raise
			end
		rescue
			puts "Could not find the defaut site! Please check your connection."
			abort
		end
		response
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
			if(@error_counter < 3)
				remaining_attempts = 3 - @error_counter
				puts "-"*40
		  	puts "The file #{user_file_path} does not exist."
				puts "Please enter the correct path."
				puts "You have #{remaining_attempts} attempts left."
				new_user_file_path = gets.chomp
				response = user_file_response(new_user_file_path)
			else
				puts "-"*40
				puts "Your last attempted was incorrect."
				puts "Redirecting you to our test word list after 3 attempts."
				response = api_response
			end
		end
		response
	end

	def word_size_hash(user_options)
		sequence_hash = {}
		new_word_size_hash = user_options.split("\n").inject(Hash.new(0)) {|word, size| if(size.length >= 4); word[size] = size.length; end; word}

		new_word_size_hash.each do |word, size|
			adjusted_size = size - 4
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
		sequence_hash
	end

	def write_sequence_output(sequence_hash)
		puts " Sequence\tWord"
		sequence_hash.each do |sequence, word|
			if(word != 0)
				File.open("sequence_list.txt", 'a') { |file| file.write("#{sequence}\n") }
				File.open("word_list.txt", 'a') { |file| file.write("#{word}\n") }
				puts "   #{sequence}        #{word}"
			end
		end
	end

end

loop_init = 0
loop_total = 1000000
start_time = Time.now

data_source = WordAPI.new
response = data_source.user_options
sequence_hash = data_source.word_size_hash(response)
data_source.write_sequence_output(sequence_hash)

stop_time = Time.now

run_time = (stop_time - start_time)
average_time = run_time/loop_total
puts "File-open total time of #{loop_total} runs: #{run_time} seconds"
puts "File-open average time: #{average_time*1000} milliseconds"
