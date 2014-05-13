module Expressr
  class Request < Noder::HTTP::Request
    attr_reader :query

    def initialize(env)
      super(env)
      @params = Hashie::Mash.new(@params)
      @query = Hashie::Mash.new(@query)
    end

    def url
      @url ||= original_url
    end

    def param(name)
      params[name]
    end

    def route
      raise NotImplementedError
    end

    def cookies
      raise NotImplementedError
    end

    def signed_cookies
      raise NotImplementedError
    end

    def get(name)
      headers[name]
    end

    def accepts(types)
      types = types.split(', ') if types.is_a?(String)
      types = [types] unless types.is_a?(Array)
      @accept_types ||= get('Accept').split(';').first.split(',')
      (types & @accept_types).first
    end

    def accepts_charset(charset)
      raise NotImplementedError
    end

    def accepts_language(language)
      raise NotImplementedError
    end

    def is?(type)
      content_type_header = headers['Content-Type']
      return false if content_type_header.nil?
      content_types = content_type_header.split('; ')
      content_types.include?(type)
    end

    def ip
      @env[:ip]
    end

    def ips
      raise NotImplementedError
    end

    def path
      @env[:request_uri]
    end

    def host
      get('Host').split(':').first
    end

    def fresh?
      raise NotImplementedError
    end

    def stale?
      raise NotImplementedError
    end

    def xhr?
      get('X-Requested-With') == 'XMLHttpRequest'
    end

    def protocol
      @env[:protocol].split('/').first.downcase
    end

    def secure?
      protocol == 'https'
    end

    def subdomains
      host.split('.')[0..-3].reverse
    end

    def locals
      @locals ||= Hashie::Mash.new
    end

    def original_url
      @original_url ||= get_original_url
    end

    protected

    def get_original_url
      url = path
      query_string = @env[:query_string]
      if query_string && query_string != ''
        url = "#{url}?#{query_string}"
      end
      url
    end

    alias_method :header, :get
  end
end
