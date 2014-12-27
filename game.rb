require_relative 'core'

class RandomPoint < Core::GameObject
  @shader = :point

  def get_gl_data
    [rand * 2 - 1, rand * 2 - 1]
  end
end

game = Core::Game.new 'sup'

3.times { game.remove_point }

game.start do
  3.times { game.remove_point }
  3.times { game.add_point RandomPoint.new }
end
