class CorrectWord
  def initialize(word)
    @word = word.downcase
  end

  def find_char(letter)
    @word.each_char.with_index.map do |char, index|
      if (char == letter)
        index
      else
        nil
      end
    end.compact
  end

  def length
    @word.length
  end

  def to_s
    @word
  end
end
