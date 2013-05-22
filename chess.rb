require 'colored'
require './pieces.rb'
require './human_player.rb'
# require 'debugger'
class Game
  attr_accessor :board, :player1, :player2

  def self.human_vs_human
    b = Board.new
    b.setup
    h1 = HumanPlayer.new(:white)
    h2 = HumanPlayer.new(:black)
    g = Game.new
    g.play(h1,h2,b)
  end

  def play(player1,player2,board)
    @player1= player1
    @player2 = player2
    @board = board

    player = @player1
    check_mate = false
    until check_mate
      get_move(player)
      player = other_player(player)
      check_mate = @board.check_mate?(player.color)
      if @board.in_check?(other_player(player).color) && !check_mate
        puts "Check!"
      end
    end

    puts "Check Mate!"

  end

  def other_player(player)
    player == @player1 ? @player2 : @player1
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

  def initialize(rows = Array.new(8) { Array.new(8) })
    @rows = rows
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

  def setup
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
      self[to] = self[from]
    else
      self[to].taken = true
      self[to] = self[from]
    end
    self[to].location = to
    self[from] = nil
  end

  def rows
    @rows.map(&:dup)
  end

  def dup
    board_new = Board.new(rows)
    board_new.rows.each do |row|
      row.each do |piece|
        piece.board = board_new unless piece.nil?
      end
    end
    board_new
  end

  def check_mate?(attacked_color)
    @rows.each_with_index do |row, x|
      row.each_with_index do |piece, y|
       next if piece.nil?
       return false if piece_can_block?(piece, attacked_color,[x,y])
      end
    end
    true
  end


  def piece_can_block?(piece, attacked_color,from)
    if piece.color == attacked_color
      piece.possible_moves.each do |to|
        board_copy = self.dup
        board_copy.move(from,to)
        board_copy.in_check?(other_color(attacked_color))
        return true if !board_copy.in_check?(other_color(attacked_color))
      end
    end
    false
  end

  def other_color(color)
    color == :black ? :white : :black
  end


  def in_check?(attacking_color)
    possible_moves = []
    king_spot = []
    @rows.each_with_index do |row, x|
      row.each_with_index do |space, y|
       next if space.nil?
       king_spot = [x,y] if space.is_a?(King) && space.color != attacking_color
       if space.color == attacking_color
         possible_moves += space.possible_moves
       end
      end
    end
    possible_moves.include?(king_spot)
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



# b[location]
