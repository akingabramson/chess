class Piece
  attr_accessor :color,:location, :name, :board

  def initialize(color,location,name,board)
    @color = color
    @location = location
    @name = name
    @board = board
  end

  def deep_dup

  end

  def taken?
    @taken
  end

  def to_s
    if @color == :white
      @name.white
    else
      @name.blue
    end
  end

  def check_moves

    possible_moves.select {|move| @board[move].is_a?(King)}
  end

end

class SlidingPiece < Piece
  def possible_moves(transforms)
    spaces = []
    transforms.each do |transform|
      spaces += generate_relative_spaces(@location,transform)
    end
    spaces
  end

  def generate_relative_spaces(loc,transform)
    x,y = loc
    dx,dy = transform
    new_loc = [(x+dx),(y+dy)]

    return [] unless @board.on_board?(new_loc)
    return [] if !@board[new_loc].nil? && @board[new_loc].color == @color

    if @board[new_loc].nil?
      return [new_loc] + generate_relative_spaces(new_loc,transform)
    elsif !@board[new_loc].nil? && @board[new_loc].color != @color
      return [new_loc]
    else
      return []
    end
  end
end

class SteppingPiece < Piece

  def possible_moves(relative_spaces)
    spaces = []
    x,y = @location

    relative_spaces.each do |rel_space|
      dx,dy = rel_space
      potential_space = [(x+dx),(y+dy)]

      if @board.on_board?(potential_space)
        if @board[potential_space].nil?
          spaces << potential_space
        elsif @board[potential_space].color != @color
          spaces << potential_space
        end
      end
    end
    spaces
 end

  # def initialize(color,location)
#     super(color,location)
#   end
end

class Pawn < Piece
  attr_accessor :move_count

  def initialize(color,location,board)
    super(color,location, "\u265F",board)
    @first_move = true
    @move_count = 0
  end

  def location=(location)
    @location = location
    @move_count += 1
  end

  def kill_moves
    spaces = []
    x, y = @location

    diag_left = [x+(1*direction),y+1]
    diag_right = [x+(1*direction),y-1]
    diagonals = [diag_left,diag_right]

    diagonals.each do |diag|
      if @board.color_at(diag) != @color &&
        !@board.color_at(diag).nil? &&
        @board.on_board?(diag)
        spaces << diag
      end
    end

    spaces
  end

  def en_moves
    en_spaces = []
    x, y = @location

    en_left = [x,y+1]
    en_right = [x,y-1]
    ens = [en_left,en_right]

    ens.each do |en|
      if !@board.last_piece_moved.nil? &&
        @board.last_piece_moved.location == en &&
        @board.last_piece_moved.move_count == 1 &&
        @board[en].color != @color
        en_spaces << [en[0]+(1*direction),en[1]]
      end
    end

    en_spaces

  end

  def possible_moves
    spaces = []
    x, y = @location

    one_ahead = [x+(1*direction),y]

    if @move_count == 0
      two_ahead = [x+(2*direction),y]

      if @board.color_at(two_ahead).nil? &&
        @board.color_at(one_ahead).nil? &&
        @board.on_board?(two_ahead)
        spaces << two_ahead
      end
    end
    if @board.color_at(one_ahead).nil? && @board.on_board?(one_ahead)
      spaces << one_ahead
    end
    spaces + kill_moves + en_moves
  end
  def direction
    @color == :black ? 1 : -1
  end
end

class Knight < SteppingPiece

  def initialize(color,location,board)
    super(color, location, "\u265E", board)
  end

  def possible_moves
    super([[2, 1], [2, -1], [1, 2], [1, -2], [-1, 2], [-1, -2], [-2, 1], [-2, -1]])
  end

end
class King < SteppingPiece

  def initialize(color,location,board)
    super(color,location, "\u265A",board)
  end
  def possible_moves
    super([[0,1], [0,-1], [-1,1], [-1,0], [-1,-1], [1,1], [1,0], [1,-1]])
  end


end

class Rook < SlidingPiece

  def initialize(color,location,board)
    super(color,location, "\u265C",board)
  end

  def possible_moves
    super([[0,1],[0,-1],[1,0],[-1,0]])
  end
end

class Bishop < SlidingPiece

  def initialize(color,location,board)
    super(color,location, "\u265D",board)
  end

  def possible_moves
    super([[1,1],[1,-1],[-1,1],[-1,-1]])
  end
end

class Queen < SlidingPiece

  def initialize(color,location,board)
    super(color,location, "\u265B",board)
  end
  def possible_moves
    super([[0,1],[0,-1],[1,0],[-1,0],[1,1],[1,-1],[-1,1],[-1,-1]])
  end

end