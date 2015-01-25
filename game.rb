require 'bundler/setup'
Bundler.require(:default)
require_relative 'core/core'

class RandomPoint < Core::GameObject
  @shader = :point

  def get_gl_data
    [rand * 2 - 1, rand * 2 - 1]
  end
end

class RandomPointSides < Core::GameObject
  @shader = :vside

  def get_gl_data
    [rand * 2 - 1, rand * 2 - 1, 1 + rand * 20]
  end
end

game = Core::Game.new

game.start do
#  100.times { game.pop_go }
#  100.times { game.pop_point }
  100.times { game.pop_vso }
#  100.times { game.push_go RandomPoint.new }
#  100.times { game.push_point RandomPoint.new }
  100.times { game.push_vso RandomPointSides.new }
end
