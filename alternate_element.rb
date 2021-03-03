require_relative 'regex_element'
class AlternateElement < RegexElement

  def initialize(repeatable, options)
    # CHECK OPTIONS> MUST BE TWO OR MORE
    @options = options
    super(repeatable)
  end

  def to_s
    element_string = ''
    return if @elements.nil?

    @elements.each { |elem| element_string.concat("#{elem.to_s}|") }
    element_string.delete_suffix('|').to_s()
  end

end