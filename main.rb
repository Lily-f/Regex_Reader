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
    @cursor = 0
  end

  def read_regex(regex)
    characters = regex.chars
    puts "regex: #{characters}"
    while @cursor < characters.length
      return unless read_character(characters)
    end

    if !@group_stack.empty?
      puts 'SYNTAX ERROR'
    else
      # Check alternation stack only has 1 entry and put onto array of elements
      @elements << @alternation_stack.pop if @alternation_stack.size == 1
      puts @elements.join(', ')
    end
  end

  def read_character(characters)
    # Read the character the cursor is pointed at and the next character if available
    char = characters[@cursor]
    read_ahead = @cursor < characters.length - 1 ? characters[@cursor + 1] : nil
    @cursor += 1

    # Check if current element is repeatable
    is_repeatable = false
    if read_ahead == '*'
      is_repeatable = true
      @cursor += 1
    end

    # Create element based on the type of character read
    case char
    when '|'
      previous_elements = []
      if @depth.zero?
        @elements.each { |elem| previous_elements << elem }
        @elements.clear
      elsif !@group_stack.last.nil? && @group_stack.last.depth == @depth
        while (elem = @group_stack.last.elements.shift)
          previous_elements << elem
        end
      end

      existing_alternation = @alternation_stack.find { |alt| alt.depth == @depth }
      if existing_alternation.nil?
        alternation = AlternateElement.new(@depth, previous_elements)
        @alternation_stack.push(alternation)
      else
        previous_elements.each { |option| existing_alternation.fill_option(option) }
        existing_alternation.add_option
      end
    when '('
      @depth += 1
      # If an alternation is at this level, add group to it
      if !@alternation_stack.empty?
        @alternation_stack.last.fill_option(GroupElement.new(@depth))
        @alternation_stack.last.open_group = true
      else
        @group_stack << GroupElement.new(@depth)
      end

    when ')'
      if !@alternation_stack.empty? && @alternation_stack.last.open_group
        @alternation_stack.last.open_group = false
        @alternation_stack.last.options.last.last.is_repeatable = is_repeatable

      elsif !@group_stack.empty?
        @group_stack.last.is_repeatable = is_repeatable
        if !@alternation_stack.empty? && @alternation_stack.last.depth == @depth
          @group_stack.last.add_element(@alternation_stack.pop)
        end

        # Add group to existing group if there is one
        if @group_stack.size > 1
          group = @group_stack.pop
          @group_stack.last.add_element(group)
        else
          @elements << @group_stack.pop
        end

      else
        # if group is in alternation, handle that
        puts 'SYNTAX ERRORR'
        return false
      end
      @depth -= 1

    else
      # handle element storage
      store_element(char, is_repeatable)
    end
    true
  end

  # Store base regex elements like chars and wilds inside the relevant group / alternation / base array
  def store_element(char, is_repeatable)
    element = create_element(char, is_repeatable)
    if !@alternation_stack.empty? && !@group_stack.empty?
      if @alternation_stack.last.depth >= @group_stack.last.depth
        @alternation_stack.last.fill_option(element)
      else
        @group_stack.last.add_element(element)
      end
    elsif !@alternation_stack.empty?
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

Regex1.new.read_regex('ab|(c|v)*')
