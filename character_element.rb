require_relative 'regex_element'

# A specific ASCII character that doesn't represent another element
class CharacterElement < RegexElement
  def initialize(is_repeatable, value)
    @value = value
    super(is_repeatable)
  end

  # Convert this character element into string representation
  def to_s
    "#{@value}:#{@is_repeatable}"
  end
end