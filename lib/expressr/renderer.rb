module Expressr
  class Renderer
    class << self
      attr_accessor :engine

      def renderer
        if engine != Expressr::App.settings['view engine']
          @renderer = get_renderer
        else
          @renderer ||= get_renderer
        end
      end

      def get_renderer
        self.engine = engines[Expressr::App.settings['view engine']]
        raise "Invalid view engine value: #{engine}" unless engine
        klass = Expressr::Utils.constantize(engine)
        klass.new
      end

      def engines
        {
          'haml' => 'Expressr::Renderers::Haml',
          'slim' => 'Expressr::Renderers::Slim'
        }
      end
    end

    def render(path, locals={})
      path = App.settings['root'].join(App.settings['views'], path)
      locals = App.settings['locals'].merge(locals)
      renderer.render(path, locals)
    end

    def renderer
      self.class.renderer
    end
  end
end
