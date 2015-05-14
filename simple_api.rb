

require 'open-uri'
# response = open('https://mercy-api.herokuapp.com/').read
response = open('https://s3.amazonaws.com/cyanna-it/misc/dictionary.txt').read
puts response
