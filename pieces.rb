class Piece
  attr_accessor :color,:location, :taken, :name, :board

  def initialize(color,location,name,board)
    @taken = false
    @color = color
    @location = location
    @name = name
    @board = board
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

    if @board[new_loc].nil?
      return [new_loc] + generate_relative_spaces(new_loc,transform)
    elsif !@board[new_loc].nil? && @board.color_at(new_loc) != @color
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
        if @board.color_at(potential_space) != @color
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
  attr_accessor :first_move

  def initialize(color,location,board)
    super(color,location, "P",board)
    @first_move = true
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


  def possible_moves
    spaces = []
    x, y = @location

    one_ahead = [x+(1*direction),y]

    if @first_move
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
    spaces + kill_moves
  end
  def direction
    @color == :black ? 1 : -1
  end
end

class Knight < SteppingPiece

  def initialize(color,location,board)
    super(color,location, "K",board)
  end

  def possible_moves
    super([[2,1], [2,-1], [1,2], [1,-2], [-1,2], [-1,-2], [-2,1], [-2,-1]])
  end

end
class King < SteppingPiece

  def initialize(color,location,board)
    super(color,location, "*",board)
  end
  def possible_moves
    super([[0,1], [0,-1], [-1,1], [-1,0], [-1,-1], [1,1], [1,0], [1,-1]])
  end


end

class Rook < SlidingPiece

  def initialize(color,location,board)
    super(color,location, "R",board)
  end

  def possible_moves
    super([[0,1],[0,-1],[1,0],[-1,0]])
  end
end

class Bishop < SlidingPiece

  def initialize(color,location,board)
    super(color,location, "B",board)
  end

  def possible_moves
    super([[1,1],[1,-1],[-1,1],[-1,-1]])
  end
end

class Queen < SlidingPiece

  def initialize(color,location,board)
    super(color,location, "Q",board)
  end
  def possible_moves
    super([[0,1],[0,-1],[1,0],[-1,0],[1,1],[1,-1],[-1,1],[-1,-1]])
  end

end