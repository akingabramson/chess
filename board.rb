#require 'debugger'

class Board
  attr_accessor :rows, :last_piece_moved

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
    x, y = location
    x.between?(0, 7) && y.between?(0, 7)
  end

  def setup
    add_pawns
    add_knights
    add_rooks
    add_bishops
    add_royalty
  end

  def move(from, to)
    #debugger
    board_copy = self.dup
    board_copy.move!(from, to)
    if board_copy.in_check?(other_color(self[from].color))
      raise MoveIntoCheckError.new("Cannot move into check.")
    end
    self.move!(from, to)
    promote_pawn(to) if self[to].is_a?(Pawn) && (to[0] == 0 || to[0] == 7)
  end

  def move!(from, to)
    raise ArgumentError.new("Cannot move from an empty space.") if self[from].nil?
    raise ArgumentError.new("Cannot move there.") unless self[from].possible_moves.include?(to)

    if en_passant?(from, to)
      self[[from[0], to[1]]] = nil
    end

    if is_castling?(from, to)
      if to[1] == 2
        move!([from[0], 0], [from[0], 3])
      else
        move!([from[0], 7], [from[0], 5])
      end
    end

    self[to] = self[from]
    self[to].location = to
    self[from] = nil

    @last_piece_moved = self[to]
  end

  def en_passant?(from, to)
    jumped_pawn_loc = [from[0], to[1]]
    if self[from].is_a?(Pawn) &&
      from[1] != to[1] &&
      self[to].nil? &&
      !self[jumped_pawn_loc].nil? &&
      self[jumped_pawn_loc].move_count == 1 &&
      @last_piece_moved.location == jumped_pawn_loc
      return true
    else
      false
    end
  end

  #can only castle from king
  def is_castling?(from, to)
    self[from].is_a?(King) && (from[1]-to[1]).abs>1
  end

  def promote_pawn(location)
    puts "Pawn made it! [K]night or [Q]ueen?"
    begin
      to_piece = gets.chomp.strip.downcase
      unless ["k","q"].include?(to_piece)
        raise ArgumentError.new("Sorry pawn cannot magically become a #{to_piece}")
      end
      if to_piece == "k"
        self[location]= Knight.new(self[location].color, location, self)
      else
        self[location]= Queen.new(self[location].color, location, self)
      end
    rescue ArgumentError => e
      puts e.message
      retry
    end
  end

  def rows
    @rows.map(&:dup)
  end

  def dup
    board_new = Board.new(rows)
    board_new.rows.each_with_index do |row, x|
      row.each_with_index do |piece, y|
        next if piece.nil?
        board_new[[x, y]] = piece.dup
        board_new[[x, y]].board = board_new
      end
    end
    board_new.last_piece_moved = @last_piece_moved
    board_new
  end

  def check_mate?(attacked_color)
    return false unless in_check?(other_color(attacked_color))

    @rows.each_with_index do |row, x|
      row.each_with_index do |piece, y|
       next if piece.nil? || piece.color != attacked_color
       return false if piece_can_block?(piece, attacked_color,[x,y])
      end
    end
    true
  end

  def piece_can_block?(piece, attacked_color,from)
    piece.possible_moves.each do |to|
      board_copy = self.dup
      board_copy.move!(from,to)
      return true if !board_copy.in_check?(other_color(attacked_color))
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
       king_spot = [x, y] if space.is_a?(King) && space.color != attacking_color
       if space.color == attacking_color
         possible_moves += space.possible_moves
       end
      end
    end
    possible_moves.include?(king_spot)
  end

  def add_pawns
    [1, 6].each do |row_num|
      @rows[row_num].each_index do |index|
        color = row_num < 4 ?  :black : :white
        @rows[row_num][index] = Pawn.new(color, [row_num, index], self)
      end
    end
  end

  def add_knights
    [0, 7].each do |row_num|
      [1, 6].each do |col_num|
        color = row_num < 4 ?  :black : :white
        @rows[row_num][col_num] = Knight.new(color, [row_num, col_num], self)
      end
    end
  end

  def add_rooks
    [0, 7].each do |row_num|
      [0, 7].each do |col_num|
        color = row_num < 4 ?  :black : :white
        @rows[row_num][col_num] = Rook.new(color, [row_num, col_num], self)
      end
    end
  end

  def add_bishops
    [0, 7].each do |row_num|
      [2, 5].each do |col_num|
        color = row_num < 4 ?  :black : :white
        @rows[row_num][col_num] = Bishop.new(color, [row_num, col_num], self)
      end
    end
  end

  def add_royalty
    @rows[0][3] = Queen.new(:black, [0, 3], self)
    @rows[0][4] = King.new(:black, [0, 4], self)
    @rows[7][3] = Queen.new(:white, [7, 3], self)
    @rows[7][4] = King.new(:white, [7, 4], self)
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
    system("clear")
    print_colnumbers
    @rows.each_with_index do |row, index|
      print "#{index}"
      row.each do |space|
        print space.nil? ? "_" : space.to_s
        print " "
      end
      puts "\n"
    end
    print_colnumbers
  end

  def print_colnumbers
    puts " 0 1 2 3 4 5 6 7"
  end

  def display_possible(possible_from)
    system("clear")
    print_colnumbers
    @rows.each_with_index do |row, x|
      print "#{x}"
      row.each_with_index do |space, y|
        if possible_from.include?([x, y])
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
    print_colnumbers
  end
end

class MoveIntoCheckError < ArgumentError
end