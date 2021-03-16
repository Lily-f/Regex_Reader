require_relative 'regex_element'

# A specific ASCII character that doesn't represent another element
class CharacterElement < RegexElement
  def initialize(is_repeatable, value)
    @value = value
    super(is_repeatable)
  end

  # evaluate characters against this regex element
  def evaluate(characters)
    if @is_repeatable
      characters = characters.drop(1) while characters.first == @value
      characters
    elsif characters.first == @value
      characters.drop(1)
    else
      false
    end
  end

  # Convert this character element into string representation
  def to_s
    "#{@value}:#{@is_repeatable}"
  end
end