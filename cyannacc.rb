

loop_init = 0
loop_total = 100000
start_time = Time.now

raw_file = File.open("trial.txt", "r")
file_string = raw_file.read.to_s
word_size_hash = file_string.split("\n").inject(Hash.new(0)){|word, size| word[size] = size.length; word}

stop_time = Time.now
run_time = (stop_time - start_time)
average_time = run_time/loop_total
# puts word_size_hash
puts "File-open total time of #{loop_total} runs: #{run_time} seconds"
puts "File-open average time: #{average_time*1000} milliseconds"
