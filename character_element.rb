require_relative 'regex_element'
# A specific ASCII character that doesn't represent another element
class CharacterElement < RegexElement
  def initialize(value, repeatable)
    @value = value
    super(repeatable)
  end

  def to_s
    "Value: #{@value}"
  end
end