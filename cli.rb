class CLI
  def initialize(game_engine)
    @engine = game_engine
  end

  def start_game
    until @engine.game_over?
      print_board
      process_move
    end

    outcome
  end

  private

  def outcome
    if @engine.won?
      puts "Congrats, you got the word!"
      print_board
    else
      puts "You've lost!"
    end
  end

  def process_move
    guess = read_valid

    if @engine.check_guess(guess)
      puts "You've found a letter!"
    else
      puts "Letter not found!"
    end
  end

  def print_board
    puts "Word: #{@engine.board}"
    puts "Lives left: #{@engine.lives}"
  end

  def read_input
    print "Guess a letter: "
    gets.chomp.downcase
  end

  def read_valid
    input = read_input
    input.match?(/\A[a-z]\z/) ? input: retry_input
  end

  def retry_input
    puts "Invalid input, please enter a letter: "
    read_valid
  end
end
