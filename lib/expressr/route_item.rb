module Expressr
  class RouteItem
    attr_reader :proc, :additional_arguments

    def initialize(proc, options)
      @proc = proc
      @path = options[:path]
      @method = options[:method]
      @content_type = options[:content_type]
      @param = options[:param] || []

      @additional_arguments = []
      set_path_token_and_param_names
    end

    def call(env, continue_method)
      @env = env
      @continue = continue_method
      @env[:request].params.merge!(params)
      @proc.call(@env[:request], @env[:response], @continue, *@additional_arguments)
      continue
      @env
    end

    def continue
      @continue.call(@env)
    end

    def matches_env?(env)
      matches_request?(env[:request])
    end

    def matches_request?(request)
      content_type_matches?(request) &&
      method_matches?(request.env) &&
      path_matches?(request.env) &&
      param_matches?(request)
    end

    def params
      if @param_values.empty?
        {}
      else
        if @param_names.empty?
          @param_names = (0..(@param_values.length - 1)).to_a
        end
        Hash[@param_names.zip(@param_values)]
      end
    end

    protected

    def set_path_token_and_param_names
      @path_token, @param_names = path_token_and_param_names(@path)
      @param_values = []
    end

    def path_token_and_param_names(path)
      if path.is_a?(String) && path =~ /:[a-z]/i
        regexp = path.gsub(/:[a-z_]+/i, '([\w_]+)')
        token = Regexp.new(regexp, Regexp::IGNORECASE)
        param_names = path.scan(/:([a-z_]+)/i).flatten
        [token, param_names]
      else
        [path, []]
      end
    end

    def content_type_matches?(request)
      return true if @content_type.nil?
      !!request.accepts([@content_type])
    end

    def method_matches?(request_env)
      return true if @method.nil?
      @method == request_env[:request_method]
    end

    def path_matches?(request_env)
      return true if @path.nil?

      token = @path_token
      request_uri = request_env[:request_uri]
      if token.is_a?(String) && request_uri.end_with?(token)
        return true
      elsif token.is_a?(Regexp) && token =~ request_uri
        @param_values = $~.to_a.drop(1)
        return true
      end
      false
    end

    def param_matches?(request)
      return true if @param.empty?
      if request.params.keys.include?(@param)
        @additional_arguments = [request.params[@param]]
        true
      else
        false
      end
    end
  end
end
