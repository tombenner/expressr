require 'pathname'

module Expressr
  class App
    extend Forwardable

    attr_reader :router, :server

    def_delegators :@router, :put, :post, :delete, :use, :route

    DEFAULTS = {
      'jsonp callback name' => 'callback',
      'locals' => {},
      'root' => nil,
      'view engine' => 'slim',
      'views' => 'views'
    }
    
    class << self
      def settings
        @settings ||= DEFAULTS
      end
    end

    def initialize(server_options={})
      @router = Router.new
      @locals = {}
      set_default_root
      @server_options = { app: self }.merge(server_options)
      @server = Noder::HTTP::Server.new(@server_options)
      @router.server = @server
      request_stack = @server.event_stack('request')
      request_stack.replace(Noder::HTTP::Listeners::Request, callback: Expressr::Listeners::Request)
      request_stack.replace(Noder::HTTP::Listeners::Response, callback: Expressr::Listeners::Response)
    end

    def set(name, value)
      settings[name] = value
    end

    def get(name_or_path, &block)
      if block
        @router.get(name_or_path, &block)
      else
        settings[name_or_path]
      end
    end

    def enable(name)
      settings[name] = true
    end

    def disable(name)
      settings[name] = false
    end

    def enabled?(name)
      settings[name] == true
    end

    def disabled?(name)
      settings[name] == false
    end

    def engine(value)
      set('view engine', value)
    end

    def param(name, &block)
      @router.add_route(block, param: name)
    end

    def all(path, &block)
      @router.add_route(block, path: path)
    end

    def locals
      settings['locals']
    end

    def render(view, options={}, &block)
      raise NotImplementedError
    end

    def listen(port=nil, address=nil, &block)
      @server_options[:port] = port if port
      @server_options[:address] = address if address
      @server.listen(@server_options[:port], @server_options[:address], {}, &block)
    end

    def close
      @server.close
    end

    def settings
      self.class.settings
    end

    private

    def set_default_root
      return if get('root')
      caller_path = caller[1].split(':')[0]
      caller_directory = File.dirname(caller_path)
      set('root', Pathname.new(caller_directory))
    end
  end
end
