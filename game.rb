require 'bundler/setup'
Bundler.require(:default)
require_relative 'core/core'

class RandomPoint < Core::GameObject
  @render_type = :point

  def get_gl_data
    [rand * 2 - 1, rand * 2 - 1]
  end
end

class RandomTriEmpty < RandomPoint
  @render_type = :otb
end

class RandomTriFilled < RandomPoint
  @render_type = :ftb
end

class RandomPointSides < RandomPoint
  @render_type = :vstb

  def get_gl_data
    super + [num_of_sides]
  end

  def num_of_sides
    rand(3..10)
  end
end

game = Core::Game.new

game.start do
   300.times { game.pop_go }
   100.times { game.push_go RandomTriEmpty.new }
   100.times { game.push_go RandomTriFilled.new }
   100.times { game.push_go RandomPointSides.new }
end
