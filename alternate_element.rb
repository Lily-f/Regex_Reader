require_relative 'regex_element'

# An element that will evaluate a string to true if one or more of its options evaluates true
# # I'm not sure how to handle if more than one option returns true because it could mean that
# different characters in the string would be read in different instances.
class AlternateElement < RegexElement
  attr_accessor :options, :container

  def initialize(elements)
    @options = [elements, []]
    @container = true
    super(false)
  end

  def add_element(element)
    if nested_child?
      @options.last.last.add_element(element)
    else
      @options.last << element
    end
  end

  def add_alternation
    if nested_child?
      @options.last.last.add_alternation
    else
      puts 'ree'
      @options << []
    end
  end

  def close_group(depth)
    @options.last.last.close_group(depth)
  end

  def nested_child?
    @options.last.last.class.method_defined?('add_element') && @options.last.last.container
  end

  # Convert this alternative element into string representation
  def to_s
    element_string = '['
    @options.each { |option| element_string.concat("#{option.join(',')}|") }
    element_string.chop.concat(']')
  end

end
