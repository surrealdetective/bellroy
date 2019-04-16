require './big_five_results_poster.rb'
require './big_five_results_text_serializer.rb'
require './big_five_results_example_text.rb'

# Convert Text to Hash
text         = EXAMPLE_TEXT
bfr_poster   = BigFiveResultsTextSerializer.new(text)
results_hash = bfr_poster.to_h
puts "Converted Big Five Results Text to Hash: #{results_hash}"

# Post Results to API
email    = 'thefifth@gmail.com'.prepend(rand(10**10).to_s)
poster   = BigFiveResultsPoster.new(results_hash: results_hash, email: email)
response = poster.post 
puts "Posted Results Hash to API and got Response: #{response.inspect}"