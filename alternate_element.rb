require_relative 'regex_element'

# An element that will evaluate a string to true if one or more of its options evaluates true
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
    possible_answers = []

    @options.each do |option|
      next if option == [] && characters != []

      temp_characters = characters
      next unless option.all? do |element|
        temp_characters = element.evaluate(temp_characters)
        temp_characters != false
      end

      possible_answers << temp_characters
    end
    return false if possible_answers.empty?
    possible_answers.min_by(&:length)
  end

  # Convert this alternative element into string representation
  def to_s
    element_string = '['
    @options.each { |option| element_string.concat("#{option.join(',')}|") }
    element_string.chop.concat(']')
  end

end
