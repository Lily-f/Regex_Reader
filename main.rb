require_relative 'wild_element'
require_relative 'group_element'
require_relative 'alternate_element'
# See doc for notes a pseudo code

# set up method to read and store the regex. verify the regex is being read properly
# set up reading of strings that will be verified against the regex.
# set up verification process. Test it. make tests?
# test against the given files. This step might need to be done sooner in the process to prevent wasted work
# write report or something i guess

# Note that alternate elements stretch as far as they can, stopping only for a bracket, another pipe, or no characters

# File.foreach('words.txt') { |line| puts line}


def read_regex(regex)

  characters = regex.chars
  puts "regex: #{characters}"

  elements = []

  index = 0
  while index < characters.length
    puts "index: #{index}"

    elements << case characters[index]
                when '.'
                  WildElement.new(false)
                when '('
                  GroupElement.new(false, [])
                when ')'
                  ')'
                when '*'
                  '*'
                when '|'
                  AlternateElement.new(false, [])
                else
                  characters[index]
                end

    puts(elements.at(elements.length - 1).to_s)
    index += 1
  end

end

read_regex('ab.|(cd)*')

# puts WildElement.new(false).to_s
# puts GroupElement.new(false, [WildElement.new(true)]).to_s

# What follows is pseudo code on how this program will run

# reach characters until an element is made. Give this element a depth based on group positions (base is depth 0)
# if this element is NOT an alternate NOR alternation then read ahead by one
# if this extra one is an alternation character then handle like so: create element using the current read characters,
# and store current elements from same group level or greater inside the alternation element and ONE of the options.
# Read ahead to find what is on the other side of the alternation and repeat handling
# Note that reading must stop if an open bracket is detected to the left or if close brackets are detected to the right
# such that the group holding the alternation is escaped / the depth becomes lower than alternation.
# ELSE if is an asterisk then set the original element as repeatable. Note repeatable is [0..infinity] times
# if the extra char was not either an asterisk or pipe then after handling the original element,
# set it as original element and repeat until there are no characters
# if an open bracket is read then handle groups like so:
# create a group element that is initially empty. store group onto stack of groups. Then repeat the above method or reading chars
# until close brackets are encountered, which remove a group from the stack.
# If it was the last group then place it on the array of elements
# Note that groups can be repeatable so read one ahead as other elements
