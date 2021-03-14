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
    if open_child?
      @elements.last.add_element(element)
    else
      @elements << element
    end
  end

  def close_group(depth, is_repeatable)

    if @depth == depth
      @container = false
      @is_repeatable = is_repeatable
    else
      @elements.last.close_group(depth)
    end
  end

  def add_alternation
    if open_child?
      @elements.last.add_alternation
    else
      previous_elements = []
      @elements.each { |elem| previous_elements << elem }
      @elements.clear
      @elements << AlternateElement.new(previous_elements)
    end
  end

  def open_child?
    @elements.last.class.method_defined?('add_element') && @elements.last.container
  end

  def evaluate(characters)
    if @is_repeatable
      repeating = true
      while repeating
        temp_characters = characters
        repeating = @elements.all? do |element|
          temp_characters = element.evaluate(temp_characters)
          temp_characters != false
        end
        characters = temp_characters if repeating
      end
      characters

    elsif @elements.all? do |element|
      characters = element.evaluate(characters)
      characters != false
    end
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
