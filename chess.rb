require 'colored'
require './pieces.rb'

class Game
  attr_accessor :board, :player1, :player2

  def self.human_vs_human
    b = Board.new
    h1 = HumanPlayer.new
    h2 = HumanPlayer.new
    g = Game.new
    g.play(h1,h2,b)
  end

  def play(player1,player2,board)
    @player1= player1
    @player2 = player2
    @board = board
    #start play loop
    #
    get_move(player1)
  end

  def get_move(player)
    begin
      from = player.get_from
      possible_from = @board[from].possible_moves
      raise ArgumentError.new("Can't move from there.") if possible_from.count == 0
    rescue ArgumentError => e
      puts e.message
      retry
    end

    @board.display_possible(from)
    to = player.get_to(possible_from)
    @board.move(from,to)
    @board.display
  end

end

class Board
  attr_accessor :rows

  def initialize
    @rows = Array.new(8) { Array.new(8) }
    set_starting_pieces
    return nil
  end

  def inspect
    display
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

    if self[from].nil?
      raise ArgumentError.new("Cannot move from an empty space.")
    end

    # unless self[from].possible_moves.include?(to)
#       raise ArgumentError.new("Cannot move there.")
#     end

    if self[to].nil?
      self[to] = self[from].dup
    else
      self[to].taken = true
      self[to] = self[from].dup
    end
      self[from] = nil
  end

  def over?

  end
  def check?(color)
    possible_checks = []

    @rows.each_with_index do |row,x|
      row.each_with_index do |space,y|
        next if space.nil?
       if self.color_at([x,y]) == color
         possible_checks += space.check_moves
       end
      end
    end

    !possible_checks.empty?

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
            print "_".yellow
          else
            print space.name.yellow
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
  def initialize
  end

  def get_input
    begin
      input = gets.chomp
      raise ArgumentError.new("You didn't put in a comma. Use (1,3) format.") unless input.include?(",")
      input = input.split(",").map(&:strip)

      if(input[0] =~ /\D/ || input[1] =~ /\D/)
        raise ArgumentError.new("You didn't input a number")
      end

      input.map!(&:to_i)

      if !input[0].between?(0,7) || !input[1].between?(0,7)
        raise ArgumentError.new("You didn't input a space on the board")
      end
      return input
    rescue ArgumentError => e
      puts e.message
      retry
    end
  end

  def get_from
    puts "Which piece do you want to move? i.e. (0,3)"
    get_input
  end

  def get_to(possible_spaces)
    puts "Where you want to move? i.e. (0,3)"
    begin
      to = get_input
      unless possible_spaces.include?(to)
        raise ArgumentError.new("Piece cannot move there.")
      end
    rescue ArgumentError => e
      puts e.message
      retry
    end
    to
  end

end

# b[location]
