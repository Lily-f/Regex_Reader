require_relative 'wild_element'
require_relative 'group_element'
# See doc for notes a pseudo code

# set up method to read and store the regex. verify the regex is being read properly
# set up reading of strings that will be verified against the regex.
# set up verification process. Test it. make tests?
# test against the given files. This step might need to be done sooner in the process to prevent wasted work
# write report or something i guess

# File.foreach('words.txt') { |line| puts line}

puts WildElement.new(false).to_s

puts GroupElement.new(false, [WildElement.new(true)]).to_s
