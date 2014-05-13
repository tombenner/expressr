module Expressr
  class Router
    attr_accessor :server

    def initialize
      @nodes = []
    end

    def use(path=nil, &block)
      add_route(block, path: path)
    end

    def param(name, &block)
      add_route(block, param: name)
    end

    def route(path)
      Route.new(router: self, path: path)
    end

    def get(path, &block)
      add_route(block, method: 'GET', path: path)
      self
    end

    def put(path, &block)
      add_route(block, method: 'PUT', path: path)
      self
    end

    def post(path, &block)
      add_route(block, method: 'POST', path: path)
      self
    end

    def delete(path, &block)
      add_route(block, method: 'DELETE', path: path)
      self
    end

    def run(request, response)
      env = {
        request: request,
        response: response
      }
      emit('request', env)
    end

    def add_route(proc, options={})
      if options[:path]
        options[:path] = standardize_path(options[:path])
      end
      callback = RouteItem.new(proc, options)
      server.add_listener('request', callback)
    end

    protected

    def standardize_path(path)
      if path == '*'
        path = nil
      elsif path.is_a?(String) && path.include?('*')
        path = Regexp.new("^#{path.gsub('*', '.*')}$")
      end
      path
    end
  end
end
