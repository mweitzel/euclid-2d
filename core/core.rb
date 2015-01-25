module Core
end

path = File.expand_path '..', __FILE__
Dir["#{path}/*.rb"].each { |rb| require rb }
