module Expressr
  module Renderers
    class Base
      def add_extension(path, extension)
        return "#{path}.#{extension}" if path.extname == ''
        path
      end
    end
  end
end
