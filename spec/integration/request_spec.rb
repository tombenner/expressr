require 'spec_helper'

describe Expressr::Request do
  include ServerIntegrationHelper

  describe '#query' do
    it 'gets the params from only the query string' do
      block = proc do |request|
        request.query.should == { 'foo' => 'bar' }
        request.params.should == { 'foo' => 'bar', 'user_id' => '1' }
      end
      block.should_receive(:call).and_call_original
      app.get('/user/:user_id', &block)
      start_app(app)
      http_get('/user/1?foo=bar')
      stop_app(app)
    end
  end

  describe '#params' do
    it 'gets the params from the query string' do
      block = proc do |request|
        request.params.should == { 'foo' => 'bar' }
      end
      block.should_receive(:call).and_call_original
      app.router.use(&block)
      start_app(app)
      http_get('/?foo=bar')
      stop_app(app)
    end

    it 'gets the params from the POST data' do
      block = proc do |request|
        request.params.should == { 'foo' => 'bar' }
      end
      block.should_receive(:call).and_call_original
      app.router.use(&block)
      start_app(app)
      http_post('/', params: { foo: 'bar' })
      stop_app(app)
    end

    it 'supports indifferent access to the params' do
      block = proc do |request|
        request.params['foo'].should == 'bar'
        request.params[:foo].should == 'bar'
        request.params.foo.should == 'bar'
      end
      block.should_receive(:call).and_call_original
      app.router.use(&block)
      start_app(app)
      http_get('/?foo=bar')
      stop_app(app)
    end
  end

  describe '#url' do
    it 'gets the url' do
      block = proc do |request|
        request.url.should == '/foo?bar=baz'
      end
      block.should_receive(:call).and_call_original
      app.router.use(&block)
      start_app(app)
      http_get('/foo?bar=baz')
      stop_app(app)
    end
  end

  describe '#protocol' do
    it 'returns the protocol' do
      block = proc do |request|
        request.protocol.should == 'http'
      end
      block.should_receive(:call).and_call_original
      app.router.use(&block)
      start_app(app)
      http_get
      stop_app(app)
    end
  end

  describe '#secure?' do
    it 'returns false if the protocol is http' do
      block = proc do |request|
        request.secure?.should be_false
      end
      block.should_receive(:call).and_call_original
      app.router.use(&block)
      start_app(app)
      http_get
      stop_app(app)
    end
  end
end
