class WordAPI
	require 'open-uri'

	def initialize
		@error_counter = 0
	end

	def user_options
		puts "This program identifies all unique 4 letter sequences from a list of words"
		print  "Would you like to use the 25K+ word default dictionary?(y/n): "
		user_data_source_choice = gets.chomp.downcase
		if(user_data_source_choice == "y" || user_data_source_choice == "yes")
			data_response = api_response
		else
			print "Please input the path to the file to be parsed: "
			file_name = gets.chomp
			data_response = user_file_response(file_name)
		end
		data_response
	end

	def api_response
		begin
			fetch_external_words = open('https://s3.amazonaws.com/cyanna-it/misc/dictionary.txt')
			if fetch_external_words
				data_response = fetch_external_words.read
			else
				raise
			end
		rescue
			puts "Could not find the defaut site! Please check your connection."
			abort
		end
		data_response
	end

	def find_file_path(user_file_path)
		starting_path = File.expand_path("~")
		if(user_file_path.include? starting_path)
			final_input_path = user_file_path
		elsif(user_file_path.include? "/")
			user_file_path.gsub!("~", "")
			final_input_path = File.expand_path("#{starting_path}#{user_file_path}")
		else
			final_input_path = user_file_path
		end
		final_input_path
	end

	def user_file_response(user_file_path)
		final_input_path = find_file_path(user_file_path)
		begin
			raw_file = File.open(final_input_path, "r")
			if raw_file
				data_response = raw_file.read.to_s
			else
				raise
			end
		rescue
			@error_counter += 1
			if(@error_counter < 3)
				remaining_attempts = 3 - @error_counter
				puts "-"*40
				puts "The file #{final_input_path} does not exist."
				puts "You have #{remaining_attempts} attempts left."
				print "Please enter the correct path: "
				new_user_file_path = gets.chomp
				data_response = user_file_response(new_user_file_path)
			else
				puts "-"*40
				puts "Your last attempt was incorrect."
				puts "Redirecting you to our test word list after 3 attempts."
				data_response = api_response
			end
		end
		data_response
	end
end

class WordSequenceGenerator

	def initialize
		@sequence_hash = {}
	end

	def generate_word_sequence_hash(user_input_text)
		word_size_hash = find_word_size(user_input_text)
		find_unique_sequence(word_size_hash)
		remove_duplicate_sequence_keys
		@sequence_hash
	end

	def find_word_size(user_input_text)
		user_input_text.split("\n").inject(Hash.new(0)) do |word, size|
			if(size.length >= 4)
				word[size] = size.length
			end
			word
		end
	end

	def find_unique_sequence(word_size_hash)
		word_size_hash.each do |word, size|
			adjusted_size = size - 4
			letter_shift_counter = 0
			for i in 0..adjusted_size
				four_letter_key = word[letter_shift_counter..(letter_shift_counter + 3)]
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

end

class FileWriter
	require 'open-uri'

	def initialize
		@print_counter = 0
	end

	def write_sequence_output(sequence_hash, raw_data)
		output_file_write(sequence_hash)
		original_word_count = raw_data.split.size
		user_results_display(original_word_count)
	end

	def output_file_write(sequence_hash)
		puts "\n Sequence\tWord"
		sequence_var = ""
		word_var = ""
		sequence_hash.each do |sequence, word|
			sequence_var = sequence_var + "#{sequence}\n"
			word_var = word_var + "#{word}\n"
			puts "   #{sequence}         #{word}" if (@print_counter < 10)
			@print_counter += 1
		end
		File.open("word_list.txt", 'w') { |file| file.write("#{word_var}\n"); file.close }
		File.open("sequence_list.txt", 'w') { |file| file.write("#{sequence_var}\n"); file.close }
	end

	def user_results_display(original_word_count)
		if (@print_counter >= 10)
			puts "\n1st 10 sequence/word combinations shown above as an example."
		else
			puts "\nAll the sequence and word combos are displayed."
		end
		puts "\n#{@print_counter} uniq sequences have be found out of #{original_word_count} words scanned."
		puts "\nTwo files have been created with all seq/word combinations:"
		puts " 1. sequence_list.txt\n 2. word_list.txt"
	end
end

user_response = WordAPI.new.user_options
sequence_hash = WordSequenceGenerator.new.generate_word_sequence_hash(user_response)
FileWriter.new.write_sequence_output(sequence_hash, user_response)
