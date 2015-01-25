module Core
  def self.error_check
    error = GL::glGetError()
    if error != GL::GL_NO_ERROR
      puts "GLError: #{error.to_s(16)}"
      puts caller
    end
#     raise "GLError: #{error.to_s(16)}" unless error == GL::GL_NO_ERROR
  end
end

path = File.expand_path '..', __FILE__
Dir["#{path}/*.rb"].each { |rb| require rb }
