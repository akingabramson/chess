

class HumanPlayer

  attr_reader :color
  def initialize(color)
    @color = color
  end

  def get_input
    begin
      input = gets.chomp
      raise ArgumentError.new("You didn't put in a comma. Use (1,3) format.")    unless input.include?(",")
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
    puts "#{@color.to_s.capitalize}: Which piece do you want to move? i.e. (0,3)"
    get_input
  end

  def get_to(possible_spaces)
    puts "#{@color.to_s.capitalize}: Where you want to move? i.e. (0,3)"
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