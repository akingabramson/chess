require 'colored'
require './pieces.rb'

class Game

end

class Board
  attr_accessor :rows

  def initialize
    @rows = Array.new(8) { Array.new(8) }
    set_starting_pieces
  end

  def color_at(location)
      selected_square = self[location]
      if selected_square
        selected_square.color
      else
        nil
      end
  end
  def on_board?(location)
    x,y = location
    x.between?(0,7) && y.between?(0,7)
  end

  def set_starting_pieces
    add_pawns
    add_knights
    add_rooks
    add_bishops
    add_royalty
  end

  def move(from,to)

  end

  def add_pawns
    [1,6].each do |row_num|
      @rows[row_num].each_index do |index|
        color = row_num < 4 ?  :black : :white
        @rows[row_num][index] = Pawn.new(color, [row_num, index],self)
      end
    end
  end

  def add_knights
    [0,7].each do |row_num|
      [1,6].each do |col_num|
        color = row_num < 4 ?  :black : :white
        @rows[row_num][col_num] = Knight.new(color, [row_num, col_num],self)
      end
    end
  end

  def add_rooks
    [0,7].each do |row_num|
      [0,7].each do |col_num|
        color = row_num < 4 ?  :black : :white
        @rows[row_num][col_num] = Rook.new(color, [row_num, col_num],self)
      end
    end
  end

  def add_bishops
    [0,7].each do |row_num|
      [2,5].each do |col_num|
        color = row_num < 4 ?  :black : :white
        @rows[row_num][col_num] = Bishop.new(color, [row_num, col_num],self)
      end
    end
  end

  def add_royalty
    @rows[0][3] = King.new(:black, [0, 3],self)
    @rows[7][4] = King.new(:white, [7, 4],self)
    @rows[0][4] = Queen.new(:black, [0, 4],self)
    @rows[7][3] = Queen.new(:white, [7, 3],self)
  end

  def []=(pos, piece)
    x, y = pos
    @rows[x][y] = piece
  end

  def [](pos)
    x, y = pos
    @rows[x][y]
  end

  def display
    puts " a b c d e f g h"
    @rows.each_with_index do |row,index|
      print "#{index}"
      row.each do |space|
        print space.nil? ? "_" : space.to_s
        print " "
      end
      puts "\n"
    end
    puts " a b c d e f g h"
  end


  def display_possible(from)
    from_piece = self[from]

    possible_moves = from_piece.possible_moves


    puts " a b c d e f g h"
    @rows.each_with_index do |row,x|
      print "#{x}"
      row.each_with_index do |space,y|
        if possible_moves.include?([x,y])
          if space.nil?
            print "_".gold
          else
            print space.name.gold
          end
        elsif space.nil?
          print "_"
        else
          print space.to_s
        end
        print " "
      end
      puts "\n"
    end
    puts " a b c d e f g h"
  end

end



class HumanPlayer

end



b = Board.new
# b[location]
b.display
p b.color_at([3,1])