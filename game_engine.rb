class GameEngine
  attr_reader :board, :lives

  def initialize(correct_word)
    @correct_word = correct_word
    @board = Board.new(@correct_word.length)
    @lives = 5
  end

  def check_guess(letter)
    change_indexes = @correct_word.find_char(letter)

    if change_indexes.any?
      @board.update_array(change_indexes, letter)
      true
    else
      @lives -= 1
      false
    end
  end
  
  def won?
    @board.complete?
  end

  def lost?
    @lives <= 0
  end

  def game_over?
    won? || lost?
  end
end
