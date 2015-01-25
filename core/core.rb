require 'yaml'
require 'glfw3'
require 'opengl-core'
require 'opengl-aux'
require 'snow-data'

module Core
  RenderTypeShaderOrder = YAML::load_file(File.join(__dir__, 'render_types.yaml'))
  def self.error_check
    error = GL::glGetError()
    if error != GL::GL_NO_ERROR
      puts "GLError: #{error.to_s(16)}"
      puts caller
    end
#     raise "GLError: #{error.to_s(16)}" unless error == GL::GL_NO_ERROR
  end
end

Dir["#{__dir__}/*.rb"].each { |rb| require rb }
