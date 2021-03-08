require_relative 'wild_element'
require_relative 'group_element'
require_relative 'alternate_element'
require_relative 'character_element'

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
    @cursor = 0
  end

  def read_regex(regex)
    characters = regex.chars
    puts "regex: #{characters}"
    read_character(characters) while @cursor < characters.length

    if @depth.positive?
      raise 'SYNTAX ERROR'
    else
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
      GroupElement.new
    when ')'
      raise 'SYNTAX ERROR' if @depth.zero?

      @elements.last.close_group
      @depth -= 1
      nil

    else
      CharacterElement.new(is_repeatable, char)
    end
  end

  def nested_child?
    @elements.last.class.method_defined?('add_element') && @elements.last.container
  end
end

Regex1.new.read_regex('a|b|(cd)*')
