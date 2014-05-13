module Expressr
  module Renderers
    directory = "#{File.dirname(File.absolute_path(__FILE__))}/renderers"

    autoload :Base, "#{directory}/base"
    autoload :Haml, "#{directory}/haml"
    autoload :Slim, "#{directory}/slim"
  end
end
