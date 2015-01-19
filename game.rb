require 'bundler/setup'
Bundler.require(:default)
require_relative 'core/core'

class RandomPoint < Core::GameObject
  @shader = :point

  def get_gl_data
    [rand * 2 - 1, rand * 2 - 1]
  end
end

game = Core::Game.new

game.start do
  300.times { game.pop_go }
  200.times { game.pop_point }
  300.times { game.push_go RandomPoint.new }
  200.times { game.push_point RandomPoint.new }
end
