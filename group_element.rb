require_relative 'regex_element'
require_relative 'alternate_element'

# A group of elements. Each must return true in order to evaluate to true
class GroupElement < RegexElement
  attr_accessor :is_repeatable, :elements, :container

  def initialize(depth)
    @depth = depth
    @elements = []
    @container = true
    super(false)
  end

  # Add a regex element to the array of elements this group contains
  def add_element(element)
    if nested_child?
      @elements.last.add_element(element)
    else
      @elements << element
    end
  end

  # Close group or nested group
  def close_group(depth, is_repeatable)
    if @depth == depth
      @container = false
      @is_repeatable = is_repeatable
    else
      @elements.last.close_group(depth, is_repeatable)
    end
  end

  # add alternation to open child if available, else this group
  def add_alternation
    if nested_child?
      @elements.last.add_alternation
    else
      previous_elements = []
      @elements.each { |elem| previous_elements << elem }
      @elements.clear
      @elements << AlternateElement.new(previous_elements)
    end
  end

  # Checks if this group contains an open group / alternation
  def nested_child?
    @elements.last.class.method_defined?('add_element') && @elements.last.container
  end

  # evaluate characters against this regex element
  def evaluate(characters)

    # If repeating, consume as many characters as possible while verification is true
    if @is_repeatable
      repeating = true
      while repeating
        temp_characters = characters
        repeating = @elements.all? { |element|
          temp_characters = element.evaluate(temp_characters)
          temp_characters != false && temp_characters.length != characters.length
        }
        characters = temp_characters if repeating
      end
      characters

    # If not repeating, check all elements in group verify
    elsif @elements.all? { |element|
      characters = element.evaluate(characters)
      characters != false
    }
      characters
    else
      false
    end
  end

  # Convert this group element into string representation
  def to_s
    element_string = '('
    @elements.each { |elem| element_string.concat("#{elem},") }
    "#{element_string.delete_suffix(',')}):#{is_repeatable}"
  end
end
