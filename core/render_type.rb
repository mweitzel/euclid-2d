module Core
  module RenderType
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

    ShaderOrder = {
      otb: [
        "core/shaders/geometry.vert",
        "core/shaders/geometry.geom",
        "core/shaders/passthru.frag" ],
      ftb: [
        "core/shaders/geometry.vert",
        "core/shaders/filled.geom",
        "core/shaders/passthru.frag" ],
      vstb: [
        "core/shaders/vside.vert",
        "core/shaders/vside.geom",
        "core/shaders/passthru.frag" ]
    }
    Buffer = {
      otb: ObjectTypeBuffer,
      ftb: ObjectTypeBuffer,
      vstb: VarSideTypeBuffer
    }
  end
end
