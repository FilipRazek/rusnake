require "ruby2d"

class Snake
  attr_writer :direction

  def initialize
    @positions = [[2, 0], [2, 1], [2, 2], [2, 3]] # Contains the positions the snake is at, from tail to head
    @direction = "down"
    @growing = false
  end

  def draw
    @positions.each do |position|
      Square.new(x: position[0] * GRID_SIZE + 1, y: position[1] * GRID_SIZE + 1, size: GRID_SIZE - 2, color: "white")
    end
  end

  def move
    if !@growing then @positions.shift end
    @growing = false

    case @direction
    when "down"
      @positions.push(new_coords(head[0], head[1] + 1))
    when "right"
      @positions.push(new_coords(head[0] + 1, head[1]))
    when "up"
      @positions.push(new_coords(head[0], head[1] - 1))
    when "left"
      @positions.push(new_coords(head[0] - 1, head[1]))
    end
  end

  def can_change_direction_to?(new_direction)
    case @direction
    when "down" then new_direction != "up"
    when "right" then new_direction != "left"
    when "up" then new_direction != "down"
    when "left" then new_direction != "right"
    end
  end

  def new_coords(x, y)
    [x % GRID_WIDTH, y % GRID_HEIGHT]
  end

  def x
    head[0]
  end

  def y
    head[1]
  end

  def grow
    @growing = true
  end

  def hit_itself?
    # The snake has hit itself when a cell appears at least twice in @positions
    @positions.uniq.length != @positions.length
  end

  private

  def head
    @positions.last
  end
end

class Game
  def initialize
    @score = 0
    @finished = false
    place_random_apple
  end

  def draw
    unless finished?
      Circle.new(x: @apple_x * GRID_SIZE + GRID_SIZE / 2, y: @apple_y * GRID_SIZE + GRID_SIZE / 2, radius: GRID_SIZE / 2, color: "green")
    end
    Text.new(text_message, color: "yellow")
  end

  def snake_ate_apple?(x, y)
    x == @apple_x && y == @apple_y
  end

  def record_ate
    @score += 1
    place_random_apple
  end

  def finish
    @finished = true
  end

  def finished?
    @finished
  end

  private

  def text_message
    unless finished? then "Score: #{@score}" else "Game over! Your final score was #{@score}. Press 'R' to restart" end
  end

  def place_random_apple
    @apple_x = rand(GRID_WIDTH)
    @apple_y = rand(GRID_HEIGHT)
  end
end

set title: "Snake"
set background: "navy"
set fps_cap: 10

# width is 640 = 32 cells by default
# height is 480 = 24 cells by default
GRID_SIZE = 20
GRID_WIDTH = Window.width / GRID_SIZE
GRID_HEIGHT = Window.height / GRID_SIZE

snake = Snake.new
game = Game.new

snake_changed_direction_on_frame = false # Stores if the direction already changed on this frame, to prevent the snake from turning around

update do
  # Runs on every frame
  clear

  unless game.finished?
    snake.move
  end
  snake_changed_direction_on_frame = false

  if game.snake_ate_apple?(snake.x, snake.y)
    game.record_ate
    snake.grow
  end

  if snake.hit_itself?
    game.finish
  end

  snake.draw
  game.draw
end

on :key_down do |event|
  if ["down", "right", "up", "left"].include?(event.key) && !snake_changed_direction_on_frame
    if snake.can_change_direction_to?(event.key)
      snake.direction = event.key
      snake_changed_direction_on_frame = true
    end
  elsif event.key == "r"
    snake = Snake.new
    game = Game.new
  end
end

show
