module Expressr
  module Renderers
    class Haml < Base
      require 'haml'

      def render(view, locals={})
        view = add_extension(view, 'haml')
        content = File.read(view)
        ::Haml::Engine.new(content).render(nil, locals)
      end
    end
  end
end
