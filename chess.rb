require 'colored'

class Game

end

class Board
  attr_accessor :rows

  def initialize
    @rows = Array.new(8) { Array.new(8) }
    set_starting_pieces
  end

  def set_starting_pieces
    add_pawns
  end

  def add_pawns
    @rows[1].each_with_index do |square, index|
      square = Pawn.new(:black, [1, index])
    end

    @rows[6].each_with_index do |square, index|
      square = Pawn.new(:white, [6, index])
    end
  end

  def []=(pos, piece)
    x, y = pos
    @rows[x][y] = piece
  end

  def [](x,y)
    x, y = pos
    @rows[x][y]
  end

  def display

    @rows.each do |row|
      puts row.inspect
    end

  end
end

b = Board.new
b.display

class HumanPlayer

end

class Piece
  attr_accessor :color,:location, :taken, :name

  def initialize(color,location,name)
    @taken = false
    @color = color
    @location = location
    @name = name
  end

  def taken?
    @taken
  end

  def to_s
    if @color == :white
      @name.white
    else
      @name.green
    end
  end

end

class SlidingPiece < Piece

end

class SteppingPiece < Piece

end

class Pawn < Piece
  attr_accessor :first_move

  def initialize(color,location)
    super(color,location, "P")

    @first_move = true
  end



end