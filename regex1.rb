require_relative 'wild_element'
require_relative 'group_element'
require_relative 'alternate_element'
require_relative 'character_element'

# Represents an array of regex elements with methods to read and create a regex from string
class Regex1
  def initialize
    @depth = 0
    @elements = []
    @cursor = 0
  end

  # reads a given string and creates a regex from it
  def run_regex(regex, message)
    characters = regex.chars
    begin
      read_character(characters) while @cursor < characters.length
    rescue RuntimeError
      puts 'SYNTAX ERROR'
      return
    end

    # Check all groups ar closed
    if @depth.positive?
      puts 'SYNTAX ERROR'
    else
      verify_message(message)
    end
  end

  # reads the next character from a given array and creates a regex element
  def read_character(characters)
    # Read the character the cursor is pointed at and the next character if available
    char = characters[@cursor]
    read_ahead = @cursor < characters.length - 1 ? characters[@cursor + 1] : nil
    @cursor += 1

    # if first char is *, throw error
    raise 'SYNTAX ERROR' if char == '*'

    # Check if current element is repeatable
    is_repeatable = false
    if read_ahead == '*'
      raise 'SYNTAX ERROR' if char == '|'

      is_repeatable = true
      @cursor += 1
    end

    # handle element storage
    element = create_element(char, is_repeatable)
    return if element.nil?

    if nested_child?
      @elements.last.add_element(element)
    else
      @elements << element
    end
  end

  # Creates a regex element from a given character and attributes
  def create_element(char, is_repeatable)
    case char
    # Create wild
    when '.'
      WildElement.new(is_repeatable)

    # Open alternation, collect previous elements at current depth
    when '|'
      previous_elements = []
      if nested_child?
        @elements.last.add_alternation
        return nil
      else
        @elements.each { |elem| previous_elements << elem }
        # puts previous_elements
        @elements.clear

      end
      AlternateElement.new(previous_elements)

    # Open new group
    when '('
      raise 'SYNTAX ERROR' if is_repeatable

      @depth += 1
      GroupElement.new(@depth)

    # Try close group at current depth
    when ')'
      raise 'SYNTAX ERROR' if @depth.zero?

      @elements.last.close_group(@depth, is_repeatable)
      @depth -= 1
      nil

    # else ASCII element
    else
      CharacterElement.new(is_repeatable, char)
    end
  end

  # Checks if the last element is an open group that nests
  def nested_child?
    @elements.last.class.method_defined?('add_element') && @elements.last.container
  end

  # Verify a message is accepted by this regex
  def verify_message(message)
    characters = message.chars

    if @elements.all? do |element|
      characters = element.evaluate(characters)
      characters != false
    end && characters.empty?
      puts 'YES'
    else
      puts 'NO'
    end
  end
end

#Regex1.new.run_regex('hello.world', 'hello world')
#return

# Collect execution arguments
input_array = ARGV

# must have 2 arguments, for regex file and string file
if input_array.length != 2
  puts 'ERROR'
  return
end

# Ensure arguments are txt files
input_array[0] = "#{input_array[0]}.txt" if input_array[0][-4..-1] != '.txt'
input_array[1] = "#{input_array[1]}.txt" if input_array[1][-4..-1] != '.txt'

# collect regexes and strings
unless File.file?(input_array[0]) && File.file?(input_array[1])
  puts 'ERROR'
  return
end
regexes = []
strings = []
File.foreach(input_array[0]) { |line| regexes << line.strip }
File.foreach(input_array[1]) { |line| strings << line.strip }

if regexes.length != strings.length
  puts 'ERROR'
  return
end

regexes.length.times do |i|
  #print("#{regexes[i].strip} with #{strings[i].strip}: ")
  Regex1.new.run_regex(regexes[i], strings[i])
end
