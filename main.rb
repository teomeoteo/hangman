# Automatically generated runner file

require_relative 'board'
require_relative 'config_loader'
require_relative 'game_engine'
require_relative 'word_selector'
require_relative 'correct_word'
require_relative 'cli'
require_relative 'savegame_manager'

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
