require_relative 'regex_element'
# A group of elements
class GroupElement < RegexElement
  def initialize(repeatable, elements)
    # CHECK NUMBER OF ELEMENTS IN GROUP IS VALID

    @elements = elements
    super(repeatable)
  end

  def to_s
    element_string = '('
    @elements.each { |elem| element_string.concat("#{elem.to_s},") }
    "#{element_string.delete_suffix(',').to_s})"
  end
end