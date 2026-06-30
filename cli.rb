class CLI
  def initialize(game_engine, sg_manager: nil)
    @engine = game_engine
    @sgm = sg_manager
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
    
    while guess == :save_game
      @sgm.save(@engine)
      guess = read_valid
    end

    while guess == :load_game
      @engine = @sgm.load(@engine)
      guess = read_valid
    end

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
    case input
    when "save"
      :save_game
    when "load"
      :load_game
    when /\A[a-z]\z/
      input
    else
      retry_input
    end
  end

  def retry_input
    puts "Invalid input, please enter a letter: "
    read_valid
  end
end
