require_relative 'wild_element'
require_relative 'group_element'
require_relative 'alternate_element'
require_relative 'character_element'
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

  depth = 0
  elements = []
  group_stack = []
  alternation_stack = []

  cursor = 0
  while cursor < characters.length

    # Read the character the cursor is pointed at and the next character if available
    char = characters[cursor]
    read_ahead = cursor < characters.length - 1 ? characters[cursor + 1] : nil
    # if last char and is alternation, add empty option to alternation?

    # Check if current element is repeatable
    is_repeatable = false
    if read_ahead == '*'
      is_repeatable = true
      cursor += 1
    end

    # Check if current element is alternation
    if char == '|'

      # put elements from this depth into alternation, and read ahead
      # Gather past elements from group stack and element array at this level and store as array
      previous_elements = []
      unless group_stack.last.nil?
        puts 'found a group'
      end

      # If alternation is depth 0, move elements array to be first option
      if depth.zero?
        elements.each { |elem| previous_elements << elem }
        elements.clear
      end

      existing_alternation = alternation_stack.find { |alt| alt.depth == depth }
      if existing_alternation.nil?
        alternation = AlternateElement.new(depth, previous_elements)
        alternation_stack.push(alternation)
      else
        previous_elements.each { |elem| existing_alternation.fill_option(elem) }
        existing_alternation.add_option
      end
      cursor += 1
      next
    end

    # handle element storage
    if !alternation_stack.last.nil? && alternation_stack.last.depth == depth
      temp = create_element(char, is_repeatable, depth)
      alternation_stack.last.fill_option(temp)
      puts alternation_stack.last.to_s
    else
      elements << create_element(char, is_repeatable, depth)
    end

    cursor += 1
  end
  # Check alternation stack only has 1 entry and put onto array of elements
  puts elements.join(', ')
end

# Creates a regex element from a given character and attributes
def create_element(character, is_repeatable, depth)
  case character
  when '.'
    WildElement.new(is_repeatable)
  when '('
    GroupElement.new(is_repeatable, depth)
  else
    CharacterElement.new(is_repeatable, character)
  end
end

read_regex('ac*|b*')

# reach characters until an element is made. Give this element a depth based on group positions (base is depth 0)
# if this element is NOT an alternate then read ahead by one

# if this extra one is an alternation character then handle: create alt element using the current read characters,
# and store current elements from same group level or greater inside the alternation element as ONE of the options.
# remove these from array of elements
# Read ahead to find what is on the other side of the alternation and repeat handling
# Note that reading must stop if an open bracket is detected to the left or if close brackets are detected to the right
# such that the group holding the alternation is escaped / the depth becomes lower than alternation.
# when the alternation element is created at the start it should be stored separately from the element array
# this is so that if the alternation contains groups,
# the groups will be added to the alternation instead of the elements
# Note this is only for groups within the alternation, not groups at a lower depth
# Note that alternations can only exist within another alternation if inside a group
# need alternation stack like group stack. same rules apply though, just prevents loss of info

# if an open bracket is read then handle groups like so:
# create a group element that is initially empty. store group onto stack of groups. Then repeat the above methods
# until close brackets are encountered, which remove a group from the stack and decrease depth.
# If it was the last group then place it on the array of elements OR into current alternation if one is open
# Note that groups can be repeatable so read one ahead as other elements

# Handling of character reader
# any regular character is handled the same way regardless of circumstance
# groups are handled differently and thus need method for controlling them
# asterisks require a non alternation element on the left. char before can't be a '|' or '('
# groups must be closed

# Add elements to the group at the top of the stack iff exists and depth greater than alternation
# if group has same depth as alternation then add to alternation, not group
# remove group from stack and add to alternation. If depth is now lower than alternation then
# move alternation to elements
# only add elements directly to elements array if there are no groups or alternations in either stack
