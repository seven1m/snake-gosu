require 'gosu'

class Snake
  def initialize(x, y, length)
    @segments = [[x, y]]
    length.times { grow }
    @direction_x = 1
    @direction_y = 0
  end

  attr_reader :segments

  def go_left
    return if @direction_x == 1
    @direction_x = -1
    @direction_y = 0
  end

  def go_right
    return if @direction_x == -1
    @direction_x = 1
    @direction_y = 0
  end

  def go_up
    return if @direction_y == 1
    @direction_x = 0
    @direction_y = -1
  end

  def go_down
    return if @direction_y == -1
    @direction_x = 0
    @direction_y = 1
  end

  def going_left?
    @direction_x == -1
  end

  def going_right?
    @direction_x == 1
  end

  def going_up?
    @direction_y == -1
  end

  def going_down?
    @direction_y == 1
  end

  def x
    @segments.first[0]
  end

  def y
    @segments.first[1]
  end

  def grow
    @segments.push(@segments.last.dup)
  end

  def move
    x_was = x
    y_was = y
    segment = @segments.pop
    segment[0] = x_was + @direction_x
    segment[1] = y_was + @direction_y
    @segments.unshift(segment)
  end

  def target(target_x, target_y)
    if target_x < x
      go_down if going_right?
      go_left
    elsif target_x > x
      go_down if going_left?
      go_right
    elsif target_y < y
      go_right if going_down?
      go_up
    elsif target_y > y
      go_right if going_up?
      go_down
    end
  end

  def ran_into?(other_snake)
    other_snake.segments.any? { |(other_x, other_y)| x == other_x && y == other_y }
  end
end

class SnakeGame < Gosu::Window
  def initialize
    super 639, 474
    self.caption = "Snake"
    @background_image = Gosu::Image.new('images/bg.png')
    @red_cube = Gosu::Image.new('images/red_cube.png')
    @green_cube = Gosu::Image.new('images/green_cube.png')
    @purple_cube = Gosu::Image.new('images/purple_cube.png')
    @snake = Snake.new(31, 23, 5)
    @bad_snake = Snake.new(rand(58), rand(43), 5)
    @apple_x = rand(58)
    @apple_y = rand(43)
    @last_moved = Time.now
  end
  
  def update
    if Gosu.button_down? Gosu::KB_LEFT
      @snake.go_left
    elsif Gosu.button_down? Gosu::KB_RIGHT
      @snake.go_right
    elsif Gosu.button_down? Gosu::KB_UP
      @snake.go_up
    elsif Gosu.button_down? Gosu::KB_DOWN
      @snake.go_down
    end
    if @snake.x < 0 || @snake.x > 58 || @snake.y < 0 || @snake.y > 43
      puts 'you lost'
      puts "you were #{@snake.segments.size} long"
      exit
    end
    if @bad_snake.x < 0
      @bad_snake.go_down
      @bad_snake.go_right
    end
    if @bad_snake.x > 58
      @bad_snake.go_down
      @bad_snake.go_left
    end
    if @bad_snake.y < 0
      @bad_snake.go_right
      @bad_snake.go_down
    end
    if @bad_snake.y > 43
      @bad_snake.go_right
      @bad_snake.go_up
    end
    return if Time.now - @last_moved < 0.15
    if @snake.x == @apple_x && @snake.y == @apple_y
      5.times { @snake.grow }
      @apple_x = rand(58)
      @apple_y = rand(43)
    end
    if @bad_snake.x == @apple_x && @bad_snake.y == @apple_y
      5.times { @bad_snake.grow }
      @apple_x = rand(58)
      @apple_y = rand(43)
    end
    if @snake.ran_into?(@bad_snake)
      puts 'you lost'
      puts "you were #{@snake.segments.size} long"
      exit
    end
    if @bad_snake.ran_into?(@snake)
      @bad_snake = Snake.new(rand(58), rand(43), 5)
    end
    @snake.move
    @bad_snake.move
    @bad_snake.target(@apple_x, @apple_y)
    @last_moved = Time.now
  end
 
  def draw
    @background_image.draw(0, 0, 0)
    @green_cube.draw(@apple_x * 11 + 1, @apple_y * 11 + 1, 0)
    @snake.segments.each do |(x, y)|
      @red_cube.draw(x * 11 + 1, y * 11 + 1, 0)
    end
    @bad_snake.segments.each do |(x, y)|
      @purple_cube.draw(x * 11 + 1, y * 11 + 1, 0)
    end
  end
end

SnakeGame.new.show
