module Expressr
  class Route
    def initialize(options={})
      @router = options[:router] || raise('No router provided')
      @path = options[:path] || raise('No path provided')
    end

    def all(&block)
      @router.add_route(block, path: @path)
      self
    end

    def get(&block)
      @router.get(@path, &block)
      self
    end

    def put(&block)
      @router.put(@path, &block)
      self
    end

    def post(&block)
      @router.post(@path, &block)
      self
    end

    def delete(&block)
      @router.delete(@path, &block)
      self
    end
  end
end
