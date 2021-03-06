require_relative 'regex_element'

# A group of elements. Each must return true in order to evaluate to true
class GroupElement < RegexElement
  attr_accessor :elements

  def initialize(is_repeatable, depth)
    @elements = []
    @depth = depth
    super(is_repeatable)
  end

  # Add a regex element to the array of elements this group contains
  def add_element(element)
    @elements << element
  end

  # Convert this group element into string representation
  def to_s
    element_string = '('
    @elements.each { |elem| element_string.concat("#{elem},") }
    "#{element_string.delete_suffix(',')})"
  end
end
