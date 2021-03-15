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

  # Add a regex element to the array of elements this group contains
  def add_element(element)
    if nested_child?
      @options.last.last.add_element(element)
    else
      @options.last << element
    end
  end

  # add alternation to open child if available, else this group
  def add_alternation
    if nested_child?
      @options.last.last.add_alternation
    else
      puts 'ree'
      @options << []
    end
  end

  # Close group or nested group
  def close_group(depth, is_repeatable)
    @options.last.last.close_group(depth, is_repeatable)
  end

  # Checks if this alternation contains an open group / alternation
  def nested_child?
    @options.last.last.class.method_defined?('add_element') && @options.last.last.container
  end

  # evaluate characters against this regex element
  def evaluate(characters)

    final_characters = false
    @options.each do |option_elements|
      temp_characters = characters
      next unless option_elements.all? do |element|
        temp_characters = element.evaluate(temp_characters)
        temp_characters != false
      end

      final_characters = temp_characters
    end

    final_characters
  end

  # Convert this alternative element into string representation
  def to_s
    element_string = '['
    @options.each { |option| element_string.concat("#{option.join(',')}|") }
    element_string.chop.concat(']')
  end

end
