class WordAPI
	require 'open-uri'

	def initialize
		@error_counter = 0
		@total_word_count = 0
		@sequence_hash = {}
	end

	def test_rspec
		describe "output" do
			it "test the output" do
				sequence_instance = WordAPI.new
	    end
		end
	end

	# prompt method to get the name of data source - default website or static file
	def user_options
		puts "This program identifies all unique 4 letter sequences from a list of words"
		print  "Would you like to use the 25K+ word default dictionary?(y/n): "
		user_data_source_choice = gets.chomp
		if(user_data_source_choice[0] == "y" || user_data_source_choice[0] == "Y")
			response = api_response
		else
			print "Please input the path to the file to be parsed: "
			file_name = gets.chomp
			response = user_file_response(file_name)
		end
		response
	end

	# data request from default website - can be expanded to accept any site
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

	# data request from user input file path name
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
				puts "Your last attempt was incorrect."
				puts "Redirecting you to our test word list after 3 attempts."
				response = api_response
			end
		end
		response
	end

	# Create a {word => wordsize } hash from input data that is \n separated
	# Use a simple for-loop to create a {uniq_sequence => word} hash
	def wsh(raw_text)
		raw_text.split("\n").inject(Hash.new(0)) do |word, size|
			@total_word_count += 1
			if(size.length >= 4)
				word[size] = size.length
			end
			word
		end
	end

	def sequence_shifted_hash(word_size)
		word_size.each do |word, size|
			adjusted_size = size - 4
			letter_shift_counter = 0
			for i in 0..adjusted_size
				four_letter_key = word[letter_shift_counter..(letter_shift_counter+3)]
				if(@sequence_hash[four_letter_key] == nil)
		    	@sequence_hash[four_letter_key] = word
				else
					@sequence_hash[four_letter_key] = 0
				end
				letter_shift_counter+=1
			end
		end
	end

	def remove_duplicate_sequence_keys
		@sequence_hash.each do |uniq_key, word|
			if(word == 0)
				 @sequence_hash.delete(uniq_key)
			 end
		end
	end

	def word_size_hash(raw_text)
		word_size = wsh(raw_text)
		sequence_shifted_hash(word_size)
		remove_duplicate_sequence_keys
		@sequence_hash
	end

	# word_list and sequence_list files write and abbreviated terminal output
	def write_sequence_output(sequence_hash)
		puts "\n Sequence\tWord"
		print_counter = 0
		sequence_var = ""
		word_var = ""
		sequence_hash.each do |sequence, word|
			sequence_var = sequence_var + "#{sequence}\n"
			word_var = word_var + "#{word}\n"
			puts "   #{sequence}         #{word}" if (print_counter < 10)
			print_counter += 1
		end
		File.open("word_list.txt", 'w') { |file| file.write("#{word_var}\n"); file.close }
	  File.open("sequence_list.txt", 'w') { |file| file.write("#{sequence_var}\n"); file.close }
		if (print_counter >= 10)
			puts "\n1st 10 sequence/word combinations shown above as an example."
		else
			puts "\nAll the sequence and word combos are displayed."
		end
		puts "\n#{print_counter} uniq sequences have be found out of #{@total_word_count} words scanned."
		puts "\nTwo files have been created with all seq/word combinations:"
		puts " 1. sequence_list.txt\n 2. word_list.txt"
	end

end

sequence_instance = WordAPI.new
response = sequence_instance.user_options
# sequence_hash = sequence_instance.wsh(response)
# puts sequence_hash

sequence_hash = sequence_instance.word_size_hash(response)
sequence_instance.write_sequence_output(sequence_hash)
