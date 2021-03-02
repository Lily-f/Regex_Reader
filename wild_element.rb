require_relative 'regex_element'
# A Wild character
class WildElement < RegexElement
  def to_s
    ". r=#{@repeatable}"
  end
end
