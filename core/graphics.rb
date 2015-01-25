require 'glfw3'
require 'opengl-core'
require 'opengl-aux'
require 'snow-data'

module Core
  class Graphics
    attr_reader :window, :vertices

    def initialize title='hello world'
      Glfw.init
      configure_gl_version
      @window = Glfw::Window.new(800, 600, title)
      @window.make_context_current

      @objecttypes = build_render_types
    end

    def compile_shaders shaders
      shaders.map { |shader| compile_shader shader }
    end

    def build_render_types
      render_type_shader_orders = {
        otb:  [ "core/shaders/geometry.vert",
                "core/shaders/geometry.geom",
                "core/shaders/passthru.frag" ],
        ftb:  [ "core/shaders/geometry.vert",
                "core/shaders/filled.geom",
                "core/shaders/passthru.frag" ],
        vstb: [ "core/shaders/vside.vert",
                "core/shaders/vside.geom",
                "core/shaders/passthru.frag" ],
      }

      types = {}

#     empty
      program = create_shader_program( *compile_shaders( render_type_shader_orders[:otb] ) )
      types[:otb] = ObjectTypeBuffer.new(program)
#     filled
      program = create_shader_program( *compile_shaders( render_type_shader_orders[:ftb] ) )
      types[:ftb] = ObjectTypeBuffer.new(program)
#     variable sided
      program = create_shader_program( *compile_shaders( render_type_shader_orders[:vstb] ) )
      types[:vstb] = VarSideTypeBuffer.new(program)

      Core::error_check

      types
    end

    def [](key)
      @objecttypes[key]
    end

    def add_object sym, gl_data
      @objecttypes[sym].add_object(gl_data)
    end

    def remove_object sym, idx=nil
      @objecttypes[sym].remove_object(idx)
    end

    def wait_events
      Glfw.wait_events
    end

    def clear_buffer
      GL::glClear GL::GL_COLOR_BUFFER_BIT | GL::GL_DEPTH_BUFFER_BIT
    end

    def draw
      @objecttypes.each { |key, type| type.draw }
      @window.swap_buffers
    end

    def terminate
      window.destroy
      Glfw.terminate
    end

    def create_shader_program(*shaders)
      program = GL::Program.new
      shaders.each { |shader| program.attach_shader shader }
      program.link
      puts "Creating shader program", program.info_log
      return program
    end

    def compile_shader(shader_path)
      ext_to_shader = {
        vert: GL::GL_VERTEX_SHADER,
        geom: GL::GL_GEOMETRY_SHADER,
        frag: GL::GL_FRAGMENT_SHADER,
      }

      shader_path_extension = shader_path.split('.').last.to_sym
      type = ext_to_shader[shader_path_extension]

      shader = GL::Shader.new type
      shader.source = File.open(shader_path).read
      shader.compile
      puts "Compiling #{shader_path}", shader.info_log
      Core::error_check
      return shader
    end


    def configure_gl_version version='3.2'
      major_version, minor_version = version.split('.').map(&:to_i)
      Glfw::Window.window_hint(Glfw::CONTEXT_VERSION_MAJOR, major_version)
      Glfw::Window.window_hint(Glfw::CONTEXT_VERSION_MINOR, minor_version)
      Glfw::Window.window_hint(Glfw::OPENGL_FORWARD_COMPAT, 1)
      Glfw::Window.window_hint(Glfw::OPENGL_PROFILE, Glfw::OPENGL_CORE_PROFILE)
    end
  end

  def self.error_check
    error = GL::glGetError()
    if error != GL::GL_NO_ERROR
      puts "GLError: #{error.to_s(16)}"
      puts caller
    end
#     raise "GLError: #{error.to_s(16)}" unless error == GL::GL_NO_ERROR
  end
end
