require 'yaml' # ConfigLoader, SavegameManager

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

class ConfigLoader
  def initialize(config_path: "config.yml")
    @config_path = config_path
  end

  def load
    return default_config unless File.exist?(@config_path)
    data = YAML.load_file(@config_path)
  end

  # make a default config file and make a hash for it for the file path and min_length
end

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

class SavegameManager
  def save(engine)
    File.write("save.yml", YAML.dump(engine.send(:to_h)))
    puts "Game saved! Continuing.."
  end

  def load(engine)
    data = YAML.safe_load(File.read("save.yml"), permitted_classes: [Symbol])
    new_correct_word = CorrectWord.new(data[:correct_word])
    engine = GameEngine.new(new_correct_word)
    engine.set_lives(data[:lives])
    engine.board.restore_array(data[:board_array])
    puts "Loaded from save!"
    puts "Loaded Word: #{engine.board}"
    puts "Lives: #{data[:lives]}"
    engine
  end
end

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

class GameEngine
  attr_reader :board, :lives, :correct_word

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

  def set_lives(int)
    @lives = int if int.is_a?(Integer)
  end

  private

  def to_h
    {
      lives: @lives,
      board_array: @board.to_a,
      correct_word: @correct_word.to_s
    }
  end
end

class Board
  def initialize(size)
    @array = Array.new(size, "_")
  end
  
  def to_s
    @array.join(" ")
  end

  def to_a
    @array.dup
  end

  def update_array(indexes, letter)
    indexes.each do |index|
      @array[index] = letter
    end
  end

  def restore_array(array)
    @array = array
  end

  def complete?
    !@array.include?("_")
  end
end

config = ConfigLoader.new.load
word_selector = WordSelector.new(file_path: config["file_path"], min_length: config["min_length"])
selected_word = word_selector.random_word
correct_word = CorrectWord.new(selected_word)
puts selected_word
puts correct_word
engine = GameEngine.new(correct_word)
savegame_manager = SavegameManager.new
cli = CLI.new(engine, sg_manager: savegame_manager)
cli.start_game
