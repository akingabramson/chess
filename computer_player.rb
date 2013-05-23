class ComputerPlayer
  attr_reader :color, :board

  def initialize(color, board)
    @color = color
    @board = board
  end

  def get_from
    random_from
  end

  def get_to(possible_spaces)
    possible_spaces.sample
  end


  def random_from
    all_piece_locs = []
    @board.rows.each do |row|
      row.each do |piece|
        if !piece.nil? && piece.color == @color
          all_piece_locs << piece.location
        end
      end
    end
    all_piece_locs.sample
  end
end