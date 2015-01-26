module Core
  class Game
    def initialize
      @graphics = Graphics.new
      @game_objects = []
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
      @game_objects.push game_object
      @graphics.add_object game_object.render_type, game_object.get_gl_data
    end

    def pop_go
      go = @game_objects.pop
      return unless go
      @graphics.remove_object go.render_type
    end
  end

  class GameObject
    @render_type = nil

    class << self
      attr_reader :render_type
    end

    def render_type
      self.class.render_type
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
