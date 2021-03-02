require_relative 'regex_element'
# A group of elements
class GroupElement < RegexElement
  def initialize(repeatable, elements)
    @elements = elements
    super(repeatable)
  end

  def to_s
    element_string = ''
    @elements.each { |elem| element_string.concat elem.to_s }
    "(#{element_string})"
  end
end