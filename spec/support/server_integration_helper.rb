require 'net/http'
require 'uri'

module ServerIntegrationHelper
  def self.included(base)
    base.let(:request_response_block) do
      proc do |request, response|
        request.should be_a(Expressr::Request)
        response.should be_a(Expressr::Response)
      end
    end

    base.let(:app) do
      sleep 0.1
      app = Expressr::App.new(port: port)
      app
    end
  end

  def http_get(path=nil)
    Net::HTTP.get_response(app_uri(path))
  end

  def http_post(path=nil, options={})
    defaults = {
      params: {}
    }
    options = defaults.merge(options)
    Net::HTTP.post_form(app_uri(path), options[:params])
  end

  def app_uri(path=nil)
    URI.parse("http://127.0.0.1:#{port}#{path}")
  end

  def start_app(app)
    Thread.new { app.listen }
    sleep 0.1
  end

  def stop_app(app)
    sleep 0.1
    app.close
  end

  def port
    8009
  end
  
  def get_empty_block
    proc {}
  end
end
