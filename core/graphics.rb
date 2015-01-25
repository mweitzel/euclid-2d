require 'glfw3'
require 'opengl-core'
require 'opengl-aux'
require 'snow-data'

module Core
  class ObjectTypeBuffer
    def initialize program

      cstruct = Snow::CStruct.new {
        float :x
        float :y
      }

      @vao = GL::VertexArray.new
      @vao.bind

      @data = cstruct[10000]
      buffer
#glVertexAttribPointer associates with currently bound GL_ARRAY_BUFFER
#id, vec size, type, normalized, stride, pointer
      GL::glVertexAttribPointer 0, 2, GL::GL_FLOAT, GL::GL_FALSE, 0, 0
      GL::glEnableVertexAttribArray 0
      Core::error_check

      @program = program
    end

    def buffer
      @buffers = GL::Buffer.new GL::GL_ARRAY_BUFFER unless @buffers
      @buffers.bind
      GL::glBufferData GL::GL_ARRAY_BUFFER, @data.bytesize, @data.address, GL::GL_DYNAMIC_DRAW
      Core::error_check
    end

    def draw
      if @current_point_count.nil?
        return
      end
      buffer
      @program.use
      @vao.bind
      GL::glDrawArrays GL::GL_POINTS, 0, @current_point_count
    end

    def add_object type_data
      @current_point_count ||= 0
      v_data = @data[@current_point_count]
      v_data.x, v_data.y = type_data
      @current_point_count += 1
    end

    def remove_object idx=nil
      @data[idx ||= @current_point_count ||= 0] = @data[@current_point_count ||= 0]
      return unless @current_point_count > 0
      @current_point_count -= 1
    end
  end

  class VarSideTypeBuffer < ObjectTypeBuffer
    def initialize program
      cstruct = Snow::CStruct.new {
        float :x
        float :y
        float :numsides
      }
      @vao = GL::VertexArray.new
      @vao.bind

      @data = cstruct[10000]
      buffer
#Stride is 3*4 because the first attrib/argument is a 2 float vector, but the data is interleaved
#So it is 3 floats between the beginning of each data object.
      GL::glVertexAttribPointer 0, 2, GL::GL_FLOAT, GL::GL_FALSE, 3*4, 0
      GL::glEnableVertexAttribArray 0
#Pointer is 2*4 because the numsides variable sits after 2 floats (2*sizeof(float))
      GL::glVertexAttribPointer 1, 1, GL::GL_FLOAT, GL::GL_FALSE, 3*4, 2*4
      GL::glEnableVertexAttribArray 1
      Core::error_check

      @program = program
    end

#buffer method stays the same because all data is still stored and updated in a single buffer array.

    def add_object type_data
      @current_point_count ||= 0
      v_data = @data[@current_point_count]
      v_data.x, v_data.y, v_data.numsides = type_data
      @current_point_count += 1
    end
  end

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
