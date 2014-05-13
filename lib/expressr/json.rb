require 'json'

module Expressr
  class JSON
    class << self
      def decode(string)
        ::JSON.load(string)
      end

      def encode(value)
        ::JSON.dump(value)
      end
    end
  end
end
