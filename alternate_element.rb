require_relative 'regex_element'

# An element that will evaluate a string to true if one or more of its options evaluates true
# # I'm not sure how to handle if more than one option returns true because it could mean that
# different characters in the string would be read in different instances.
class AlternateElement < RegexElement
  attr_accessor :depth, :open_group, :options

  def initialize(depth, elements)
    @options = [elements, []]
    @depth = depth
    @open_group = false
    super(false)
  end

  def add_option
    @options << []
  end

  def fill_option(element)
    # if latest element is group, add element to that group
    if @open_group
      @options.last.last.add_element(element)
    else
      @options.last << element
    end
  end

  # Convert this alternative element into string representation
  def to_s
    element_string = '['
    @options.each { |option| element_string.concat("#{option.join(',')}|") }
    element_string.chop.concat("]:#{@open_group}")
  end

end
