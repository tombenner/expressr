module Expressr
  module Renderers
    class Slim < Base
      require 'slim'

      def render(view, locals={})
        view = add_extension(view, 'slim')
        ::Slim::Template.new(view).render(nil, locals)
      end
    end
  end
end
