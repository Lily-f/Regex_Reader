require_relative 'regex_element'

# A Wild character
class WildElement < RegexElement

  # Convert this wild element into string representation
  def to_s
    ". r=#{@is_repeatable}"
  end
end
