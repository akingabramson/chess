require 'colored'
require './pieces.rb'
require './human_player.rb'
require './board.rb'

class Chess
  attr_accessor :board, :player1, :player2

  def self.human_vs_human
    b = Board.new
    b.setup
    h1 = HumanPlayer.new(:white)
    h2 = HumanPlayer.new(:black)
    g = Chess.new
    g.play(h1, h2, b)
  end

  def play(player1, player2, board)
    @player1 = player1
    @player2 = player2
    @board = board

    player = @player1
    check_mate = false
    @board.display

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
      raise ArgumentError.new("Cannot move from an empty space.") if @board[from].nil?
      raise ArgumentError.new("Can't move other player piece!") if @board[from].color != player.color
      possible_from = @board[from].possible_moves
      raise ArgumentError.new("Can't move from there.") if possible_from.count == 0
    rescue ArgumentError => e
      puts e.message
      retry
    end

    @board.display_possible(possible_from)
    begin
      to = player.get_to(possible_from)
      @board.move(from, to)
    rescue ArgumentError => e
      p e.message
      retry
    end
    @board.display
  end

end

Chess.human_vs_human