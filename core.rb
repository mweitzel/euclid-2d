require 'glfw3'
require 'opengl-core'
require 'opengl-aux'
require 'snow-data'

module Core
  class Game
    def initialize title='@weitzelb'
      Glfw.init
      configure_gl_version
      @window = Glfw::Window.new(800, 600, title)
      @window.make_context_current

      vaos = GL::VertexArray.new
      vaos.bind
      error_check

      vertex_shader = compile_shader GL::GL_VERTEX_SHADER, "geometry.vert"
      geometry_shader = compile_shader GL::GL_GEOMETRY_SHADER, "geometry.geom"
      fragment_shader = compile_shader GL::GL_FRAGMENT_SHADER, "passthru.frag"
      error_check

      program = create_shader_program vertex_shader, geometry_shader, fragment_shader
      program.use
      error_check

      prep_points
      buffer

      GL::glVertexAttribPointer 0, 2, GL::GL_FLOAT, GL::GL_FALSE, 0, 0
      GL::glEnableVertexAttribArray 0
      error_check
    end

    def start &block
      buffer
      until @window.should_close?
        Glfw.wait_events
        GL::glClear GL::GL_COLOR_BUFFER_BIT | GL::GL_DEPTH_BUFFER_BIT


        block.call if block
        buffer

        GL::glDrawArrays GL::GL_POINTS, 0, @current_point_count
        @window.swap_buffers
      end

      @window.destroy
      Glfw.terminate
    end

    def error_check
      error = GL::glGetError()
      raise "GLError: #{error.to_s(16)}" unless error == GL::GL_NO_ERROR
    end

    def compile_shader(type, path)
      shader = GL::Shader.new type
      shader.source = File.open(path).read
      shader.compile
      puts "Compiling #{path}", shader.info_log
      return shader
    end

    def create_shader_program(*shaders)
      program = GL::Program.new
      shaders.each { |shader| program.attach_shader shader }
      program.link
      puts "Creating shader program", program.info_log
      return program
    end

    def configure_gl_version version='3.2'
      major_version, minor_version = version.split('.').map(&:to_i)
      Glfw::Window.window_hint(Glfw::CONTEXT_VERSION_MAJOR, major_version)
      Glfw::Window.window_hint(Glfw::CONTEXT_VERSION_MINOR, minor_version)
      Glfw::Window.window_hint(Glfw::OPENGL_FORWARD_COMPAT, 1)
      Glfw::Window.window_hint(Glfw::OPENGL_PROFILE, Glfw::OPENGL_CORE_PROFILE)
    end



    def buffer
      @buffers = GL::Buffer.new GL::GL_ARRAY_BUFFER unless @buffers
      @buffers.bind
      GL::glBufferData GL::GL_ARRAY_BUFFER, @vertices.bytesize, @vertices.address, GL::GL_STATIC_DRAW
      error_check
    end

    def add_point game_object
      @current_point_count ||= 0
      vert = @vertices[@current_point_count]
      vert.x, vert.y = game_object.get_gl_data
      @current_point_count += 1
    end

    def remove_point_at_index i
    end

    def remove_point
      @current_point_count ||= 0
      return unless @current_point_count > 0
      @current_point_count -= 1
    end

    def prep_points
      vertex2 = Snow::CStruct.new {
        float :x
        float :y
      }
      @vertices = vertex2[10000]
    end
  end

  class GameObject
    class << self
      attr_accessor :shader
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
