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
class Regex1
  def initialize
    @depth = 0
    @elements = []
    @group_stack = []
    @alternation_stack = []
  end

  def read_regex(regex)
    characters = regex.chars
    puts "regex: #{characters}"

    cursor = 0
    while cursor < characters.length

      # Read the character the cursor is pointed at and the next character if available
      char = characters[cursor]
      read_ahead = cursor < characters.length - 1 ? characters[cursor + 1] : nil
      cursor += 1

      # Check if current element is repeatable
      is_repeatable = false
      if read_ahead == '*'
        is_repeatable = true
        cursor += 1
      end

      # Create element based on the type of character read
      case char
      when '|'
        # put elements from this depth into alternation, and read ahead
        # Gather past elements from group stack and element array at this level and store as array
        previous_elements = []
        unless @group_stack.last.nil?
          puts 'alternation needs to be filled from group'
        end

        # If alternation is depth 0, move elements array to be first option
        if @depth.zero?
          @elements.each { |elem| previous_elements << elem }
          @elements.clear
        end

        existing_alternation = @alternation_stack.find { |alt| alt.depth == @depth }
        if existing_alternation.nil?
          alternation = AlternateElement.new(@depth, previous_elements)
          @alternation_stack.push(alternation)
        else
          previous_elements.each { |elem| existing_alternation.fill_option(elem) }
          existing_alternation.add_option
        end
      when '('
        @depth += 1
        @group_stack << GroupElement.new(@depth)
      when ')'
        if @group_stack.empty?
          puts 'SYNTAX ERROR'
          return
        else
          @group_stack.last.is_repeatable = is_repeatable
          # TODO: Change where group element is stored
          # TODO: Check if alternation needs to be added
          @elements << @group_stack.pop
        end
      else
        # handle element storage
        store_element(char, is_repeatable)
      end
    end

    if !@group_stack.empty?
      puts 'SYNTAX ERROR'
    else
      # Check alternation stack only has 1 entry and put onto array of elements
      @elements << @alternation_stack.pop
      puts @elements.join(', ')
    end
  end

  def store_element(char, is_repeatable)
    element = create_element(char, is_repeatable)
    if !@alternation_stack.empty? && !@group_stack.empty?
      if @alternation_stack.last.depth >= @group_stack.last.depth
        @alternation_stack.last.fill_option(element)
      else
        @group_stack.last.add_element(element)
      end
    elsif !@alternation_stack.empty? && @alternation_stack.last.depth == @depth
      @alternation_stack.last.fill_option(element)
    elsif !@group_stack.empty?
      @group_stack.last.add_element(element)
    else
      @elements << element
    end
  end

  # Creates a regex element from a given character and attributes
  def create_element(char, is_repeatable)
    if char == '.'
      WildElement.new(is_repeatable)
    else
      CharacterElement.new(is_repeatable, char)
    end
  end
end

Regex1.new.read_regex('(a|b)')

# TODO: check for empty alternation options

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
