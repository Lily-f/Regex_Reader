require_relative 'wild_element'
require_relative 'group_element'
require_relative 'alternate_element'
require_relative 'character_element'

# set up reading of strings that will be verified against the regex.
# set up verification process. Test it. make tests?
# test against the given files. This step might need to be done sooner in the process to prevent wasted work
# write report

# File.foreach('words.txt') { |line| puts line}

# Represents an array of regex elements with methods to read and create a regex from string
class Regex1
  def initialize
    @depth = 0
    @elements = []
    @cursor = 0
  end

  # reads a given string and creates a regex from it
  def read_regex(regex, message)
    characters = regex.chars
    begin
      read_character(characters) while @cursor < characters.length
    rescue RuntimeError
      puts 'SYNTAX ERROR'
      return
    end

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

    # Check if current element is repeatable
    is_repeatable = false
    if read_ahead == '*'
      raise 'SYNTAX ERROR' if char == '|'

      is_repeatable = true
      @cursor += 1
    end

    # handle element storage
    element = create_element(char, is_repeatable)
    store_element(element) unless element.nil?
  end

  # Store base regex elements like chars and wilds inside the relevant group / alternation / base array
  def store_element(element)
    if nested_child?
      @elements.last.add_element(element)
    else
      @elements << element
    end
  end

  # Creates a regex element from a given character and attributes
  def create_element(char, is_repeatable)
    case char
    when '.'
      WildElement.new(is_repeatable)

    when '|'
      previous_elements = []
      if nested_child?
        @elements.last.add_alternation
        return nil
      else
        @elements.each { |elem| previous_elements << elem }
        @elements.clear

      end
      AlternateElement.new(previous_elements)

    when '('
      @depth += 1
      GroupElement.new(@depth)
    when ')'
      raise 'SYNTAX ERROR' if @depth.zero?

      @elements.last.close_group(@depth, is_repeatable)
      @depth -= 1
      nil

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

Regex1.new.read_regex('(ab)*c', 'c')

