random_number = rand(0..1)

words = File.open("google-10000-english-no-swears.txt", "r")

random_line = words.readlines.sample.chomp

words.close

puts random_line

random_line.chomp.each_char do |char|
  print "_ "
end

puts "\n"

puts "Pick a letter"

letter = gets.chomp

if random_line.include?(letter)
  puts "ima ga"
else
  puts "nema ga"
end

# puts words.gets
# puts random_number
