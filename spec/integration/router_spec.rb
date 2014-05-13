require 'spec_helper'

describe Expressr::Router do
  include ServerIntegrationHelper

  describe '#use' do
    context 'no arguments' do
      it 'calls the block with a request and response' do
        block = request_response_block
        block.should_receive(:call).and_call_original
        app.router.use(&block)
        start_app(app)
        http_get
        stop_app(app)
      end
    end

    context 'matched string path' do
      it 'calls the block with a request and response' do
        block = request_response_block
        block.should_receive(:call).and_call_original
        app.router.use('/foo', &block)
        start_app(app)
        http_get('/foo')
        stop_app(app)
      end
    end

    context 'unmatched string path' do
      it 'does not call the block' do
        block = proc {}
        block.should_not_receive(:call)
        app.router.use('/foo', &block)
        start_app(app)
        http_get('/bar')
        stop_app(app)
      end
    end

    context 'matched regex path' do
      it 'calls the block with a request and response' do
        block = request_response_block
        block.should_receive(:call).and_call_original
        app.router.use(/^\/[a-z]oo/, &block)
        start_app(app)
        http_get('/foo')
        stop_app(app)
      end
    end

    context 'unmatched regex path' do
      it 'does not call the block' do
        block = proc {}
        block.should_not_receive(:call)
        app.router.use(/^\/[a-z]aa/, &block)
        start_app(app)
        http_get('/foo')
        stop_app(app)
      end
    end

    context 'path with params' do
      it 'sets the params' do
        block = proc do |request|
          request.params.should == { 'foo' => 'baz', 'bar' => '1' }
        end
        block.should_receive(:call).and_call_original
        app.router.use('/user/:foo/comment/:bar', &block)
        start_app(app)
        http_get('/user/baz/comment/1')
        stop_app(app)
      end
    end

    it 'preserves modifications to a request' do
      block1 = proc { |request| request.env[:foo] = 'bar' }
      block2 = proc { |request| request.env[:foo].should == 'bar' }
      app.router.use(&block1)
      app.router.use(&block2)
      block1.should_receive(:call).and_call_original
      block2.should_receive(:call).and_call_original
      start_app(app)
      http_get
      stop_app(app)
    end
  end

  describe '#param' do
    context 'matched param' do
      it 'calls the block and passes the param' do
        block = proc do |request, response, continue, foo|
          foo.should == 'bar'
        end
        block.should_receive(:call).and_call_original
        app.router.param('foo', &block)
        start_app(app)
        http_get('/?foo=bar')
        stop_app(app)
      end
    end

    context 'unmatched param' do
      it 'does not call the block' do
        block = proc {}
        block.should_not_receive(:call)
        app.router.param('foo', &block)
        start_app(app)
        http_get('/?bar=baz')
        stop_app(app)
      end
    end 
  end

  describe '#get' do
    context 'GET with a matched string path' do
      it 'calls the block with a request and response' do
        block = request_response_block
        block.should_receive(:call).and_call_original
        app.router.get('/foo', &block)
        start_app(app)
        http_get('/foo')
        stop_app(app)
      end
    end

    context 'GET with an unmatched string path' do
      it 'does not call the block' do
        block = proc {}
        block.should_not_receive(:call)
        app.router.get('/foo', &block)
        start_app(app)
        http_get('/bar')
        stop_app(app)
      end
    end

    context 'POST with a matched string path' do
      it 'does not call the block' do
        block = proc {}
        block.should_not_receive(:call)
        app.router.get('/foo', &block)
        start_app(app)
        http_post('/foo')
        stop_app(app)
      end
    end
  end

  describe '#post' do
    context 'POST with a matched string path' do
      it 'calls the block with a request and response' do
        block = request_response_block
        block.should_receive(:call).and_call_original
        app.router.post('/foo', &block)
        start_app(app)
        http_post('/foo')
        stop_app(app)
      end
    end

    context 'POST with an unmatched string path' do
      it 'does not call the block' do
        block = proc {}
        block.should_not_receive(:call)
        app.router.post('/foo', &block)
        start_app(app)
        http_post('/bar')
        stop_app(app)
      end
    end

    context 'GET with a matched string path' do
      it 'does not call the block' do
        block = proc {}
        block.should_not_receive(:call)
        app.router.post('/foo', &block)
        start_app(app)
        http_get('/foo')
        stop_app(app)
      end
    end
  end
end
