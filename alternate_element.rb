require_relative 'regex_element'

# An element that will evaluate a string to true if one or more of its options evaluates true
# # I'm not sure how to handle if more than one option returns true because it could mean that
# different characters in the string would be read in different instances.
class AlternateElement < RegexElement
  attr_accessor :depth

  def initialize(depth, elements)
    @options = [elements, []]
    @depth = depth
    super(false)
  end

  def add_option
    @options << []
  end

  def fill_option(element)
    @options.last << element
  end

  # Convert this alternative element into string representation
  def to_s
    element_string = '['
    @options.each { |option| element_string.concat("#{option.join(',')}|") }
    element_string.chop.concat(']')
  end

end
