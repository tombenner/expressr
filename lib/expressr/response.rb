require 'cgi'

module Expressr
  class Response < Noder::HTTP::Response
    DEFAULT_STATUS = 200

    attr_accessor :cookies, :locals, :status
    attr_reader :request

    def initialize(env)
      super(env)
      @request = env[:request]
      @cookies = {}
    end

    # Defining #status(status) conflicts with EventMachine::DelegatedHttpResponse's #status

    def set(key_or_hash, value=nil)
      if key_or_hash.is_a?(Hash)
        hash = key_or_hash
        hash.each do |key, value|
          set_header(key, value)
        end
      else
        key = key_or_hash
        set_header(key, value)
      end
    end

    def get(key)
      get_header(key)
    end

    def cookie(name, value, options={})
      options = { 'name' => name, 'value' => value }.merge(options)
      @cookies[name] = CGI::Cookie::new(options)
      set_cookies
    end

    def clear_cookie(name, options={})
      cookie(name, '', options)
    end

    def redirect(status_or_url, url=nil)
      if url
        status = status_or_url
      else
        status = 302
        url = status_or_url
      end
      write_head(status)
      location(url)
      self.end
    end

    def location(url)
      set_header('Location', url)
    end

    # Equivalent of Express.js's send
    def out(status_or_content=nil, content=nil)
      if status_or_content.is_a?(Integer)
        status = status_or_content
      else
        status = DEFAULT_STATUS
        content = status_or_content || ''
      end
      if content.is_a?(Hash) || content.is_a?(Array)
        json(status, content)
      else
        type('text/html') unless get('Content-Type')
        write_head(status)
        write(content)
        self.end
      end
    end

    def json(status_or_body, body=nil)
      if status_or_body.is_a?(Integer)
        status = status_or_body
      else
        status = DEFAULT_STATUS
        body = status_or_body
      end
      type('application/json')
      write_head(status)
      write(Expressr::JSON.encode(body))
      self.end
    end

    def jsonp(status_or_body, body=nil)
      callback_name = Expressr::App.settings['jsonp callback name']
      callback = params[callback_name]
      if callback.nil?
        json(status_or_body, body)
        return
      end
      if status_or_body.is_a?(Integer)
        status = status_or_body
      else
        status = DEFAULT_STATUS
        body = status_or_body
      end
      type('application/javascript')
      write_head(status)
      body = Expressr::JSON.encode(body)
      body = "#{callback}(#{body});"
      write(body)
      self.end
    end

    def type(value)
      set_header('Content-Type', value)
    end

    def format(hash)
      hash.each do |content_type, proc|
        content_type = Utils.standardize_content_type(content_type)
        if request.accepts(content_type)
          proc.call(@request, self)
        end
      end
    end

    def attachment(filename=nil)
      content_disposition = 'attachment'
      if filename
        basename = File.basename(filename)
        content_disposition += %Q|; filename="#{basename}"|
        content_type = MIME::Types.type_for(filename).first.to_s
        type(content_type)
      end
      set_header('Content-Disposition', content_disposition)
    end

    def send_file(path, options={})
      root = nil
      if options[:root] && !path.start_with?('/')
        root = Pathname.new(options[:root])
      elsif App.settings['root']
        root = App.settings['root']
      end
      path = root.join(path).to_s if root
      attachment(path) unless options[:bypass_headers]
      write(read_file(path))
      self.end
    end

    def download(path, filename=nil)
      attachment(filename || path)
      send_file(path, bypass_headers: true)
    end

    def links(links)
      value = links.map { |key, url| %Q|<#{url}>; rel="#{key}"| }.join(', ')
      set_header('Link', value)
    end

    def locals
      @locals ||= {}
    end

    def render(view, locals=nil, &block)
      body = nil
      begin
        body = Renderer.new.render(view, locals)
      rescue Exception => e
        if block
          block.call(e)
        else
          raise
        end
      end
      out(body)
    end

    protected

    def read_file(path)
      File.open(path, 'rb').read
    end

    def set_cookies
      cookie_string = @cookies.values.map(&:to_s).join("\nSet-Cookie: ")
      set_header('Set-Cookie', cookie_string)
    end
  end
end
