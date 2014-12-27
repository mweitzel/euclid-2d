#!/usr/bin/env ruby -w
# reworking the first example from the Red Book 8th ed.
# https://github.com/kestess/opengl8thfirstexample

require 'glfw3'
require 'opengl-core'
require 'opengl-aux'
require 'snow-data'

include GL

class Utils
  def self.error_check
    error = glGetError()
    raise "GLError: #{error.to_s(16)}" unless error == GL_NO_ERROR
  end

  def self.compile_shader(type, path)
    shader = Shader.new type
    shader.source = File.open(path).read
    shader.compile
    puts "Compiling #{path}", shader.info_log
    return shader
  end

  def self.create_shader_program(*shaders)
    program = Program.new
    shaders.each { |shader| program.attach_shader shader }
    program.link
    puts "Creating shader program", program.info_log
    return program
  end

  def self.configure_gl_version version='3.2'
    major_version, minor_version = version.split('.').map(&:to_i)
    Glfw::Window.window_hint(Glfw::CONTEXT_VERSION_MAJOR, major_version)
    Glfw::Window.window_hint(Glfw::CONTEXT_VERSION_MINOR, minor_version)
    Glfw::Window.window_hint(Glfw::OPENGL_FORWARD_COMPAT, 1)
    Glfw::Window.window_hint(Glfw::OPENGL_PROFILE, Glfw::OPENGL_CORE_PROFILE)
  end
end

Glfw.init
Utils.configure_gl_version
window = Glfw::Window.new(800, 600, "Hello Triangles")
window.make_context_current

vaos = VertexArray.new
vaos.bind
Utils.error_check

def buffer
  @buffers = Buffer.new GL_ARRAY_BUFFER unless @buffers
  @buffers.bind
  glBufferData GL_ARRAY_BUFFER, @vertices.bytesize, @vertices.address, GL_STATIC_DRAW
  Utils.error_check
end

def reset_points
  remove_point
  remove_point
  remove_point
  add_point
  add_point
  add_point
  buffer
end

def add_point
  @current_point_count ||= 0
  vert = @vertices[@current_point_count]
  vert.x, vert.y = rand * 2 - 1, rand * 2 - 1
  @current_point_count += 1
end

def remove_point
  return unless @current_point_count
  @current_point_count -= 1
end

def prep_points
  vertex2 = Snow::CStruct.new {
    float :x
    float :y
  }
  @vertices = vertex2[10000]
end

prep_points
reset_points

vertex_shader = Utils.compile_shader GL_VERTEX_SHADER, "geometry.vert"
geometry_shader = Utils.compile_shader GL_GEOMETRY_SHADER, "geometry.geom"
fragment_shader = Utils.compile_shader GL_FRAGMENT_SHADER, "passthru.frag"
Utils.error_check

program = Utils.create_shader_program vertex_shader, geometry_shader, fragment_shader
program.use
Utils.error_check

glVertexAttribPointer 0, 2, GL_FLOAT, GL_FALSE, 0, 0
glEnableVertexAttribArray 0
Utils.error_check


until window.should_close?
  Glfw.wait_events
  glClear GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT

  reset_points

  glDrawArrays GL_POINTS, 0, @current_point_count
  window.swap_buffers
end

window.destroy
Glfw.terminate
