module Core
  class Game
    def initialize
      @graphics = Graphics.new
    end

    def start &update_block
      until quit_game?
        @graphics.wait_events
        @graphics.clear_buffer
        update_block.call if update_block
        @graphics.draw
      end
      @graphics.terminate
    end

    def quit_game?
      @graphics.window.should_close?
    end

    def push_go game_object
      @graphics.add_object :otb, game_object.get_gl_data
    end

    def pop_go
      @graphics.remove_object :otb
    end

    def push_point game_object
      @graphics.add_object :ftb, game_object.get_gl_data
    end

    def pop_point
      @graphics.remove_object :ftb
    end

    def push_vso game_object
      @graphics.add_object :vstb, game_object.get_gl_data
    end

    def pop_vso
      @graphics.remove_object :vstb
    end
  end

  class GameObject
    @shader = nil

    class << self
      attr_reader :shader
    end

    @open_gl_index

    def update_gl_index index
      @open_gl_index = index
    end

    def destroy
      remove_point_at_index @open_gl_index
    end
  end
end
