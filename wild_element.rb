require_relative 'regex_element'
# A Wild character
class WildElement < RegexElement
  def display
    puts ". r=#{@repeatable}"
  end
end
