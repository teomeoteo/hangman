require 'yaml' 

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
