class WordSelector
  def initialize(file_path:, min_length: 5)
    @file_path = file_path
    @min_length = min_length
  end

  def random_word
    valid_words.sample
  end

  private

  def all_words
    File.readlines(@file_path, chomp: true) #create a fallback word list
  end

  def valid_words
    all_words.select { |word| word.length >= @min_length }
  end
end
