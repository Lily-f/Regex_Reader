require_relative 'regex_element'

# A Wild character
class WildElement < RegexElement

  # evaluate characters against this regex element
  def evaluate(characters)
    if @is_repeatable
      []
    elsif characters.length.positive?
      characters.drop(1)
    else
      false
    end
  end

  # Convert this wild element into string representation
  def to_s
    ". r=#{@is_repeatable}"
  end
end
