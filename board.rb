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
