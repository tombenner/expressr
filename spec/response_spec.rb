require 'spec_helper'

describe Expressr::Response do
  let(:spec_root) { File.expand_path('..', __FILE__) }
  let(:file_root) { File.expand_path('../files', __FILE__) }
  let(:response) do
    request = double
    request.stub(:params) { {} }
    env = {
      request: request
    }
    response = described_class.new(env)
    response.stub(:send_data)
    response.stub(:close_connection_after_writing)
    response
  end

  before :all do
    Expressr::App.settings['root'] = Pathname.new(File.expand_path('..', __FILE__))
    Expressr::App.settings['views'] = 'files'
  end

  describe '#set' do
    it 'sets headers from a hash' do
      hash = {
        'foo' => 'bar',
        'bar' => 'baz'
      }
      response.should_receive(:set_header).with('foo', 'bar').once
      response.should_receive(:set_header).with('bar', 'baz').once
      response.set(hash)
    end

    it 'sets headers from name and value' do
      name, value = 'foo', 'bar'
      response.should_receive(:set_header).with(name, value).once
      response.set(name, value)
    end
  end

  describe '#get' do
    it 'gets the header' do
      response.should_receive(:get_header).with('foo')
      response.get('foo')
    end
  end

  describe '#cookie' do
    it 'sets the cookie' do
      name, value = 'foo', 'bar'
      response.cookie(name, value)
      response.cookies['foo'].should be_a(CGI::Cookie)
      response.cookies['foo'].value.first.should == value
    end
  end

  describe '#clear_cookie' do
    it 'clears the cookie' do
      name, value = 'foo', 'bar'
      response.cookie(name, value)
      response.clear_cookie(name)
      response.cookies['foo'].value.first.should == ''
    end
  end

  describe '#redirect' do
    it 'sets the specified status' do
      response.redirect(123, 'foo')
      response.status.should == 123
    end

    it 'sets the status to 302 if no status is provided' do
      response.redirect('foo')
      response.status.should == 302
    end

    it 'calls location and end' do
      response.should_receive(:location).with('foo').ordered
      response.should_receive(:end).ordered
      response.redirect('foo')
    end
  end

  describe '#location' do
    it 'sets the location header' do
      response.should_receive(:set_header).with('Location', 'foo').once
      response.location('foo')
    end
  end

  describe '#out' do
    it 'writes a string with type text/html' do
      string = 'foo'
      response.should_receive(:type).with('text/html').ordered
      response.should_receive(:write_head).with(200).ordered
      response.should_receive(:write).with(string).ordered
      response.should_receive(:end).ordered
      response.out(string)
    end

    it 'writes a string with a specified type' do
      string = 'foo'
      response.should_receive(:write_head).with(123).ordered
      response.should_receive(:write).with(string).ordered
      response.should_receive(:end).ordered
      response.out(123, string)
    end

    it 'writes a hash as JSON' do
      hash = { foo: 'bar' }
      response.should_receive(:json).with(described_class::DEFAULT_STATUS, hash)
      response.out(hash)
    end

    it 'writes a hash with a specified type as JSON' do
      hash = { foo: 'bar' }
      response.should_receive(:json).with(123, hash)
      response.out(123, hash)
    end

    it 'writes an array as JSON' do
      array = [1, 'foo']
      response.should_receive(:json).with(described_class::DEFAULT_STATUS, array)
      response.out(array)
    end
  end

  describe '#json' do
    it 'sets the type' do
      response.should_receive(:type).with('application/json')
      response.json({ foo: 'bar' })
    end

    it 'writes the JSON' do
      response.should_receive(:write).with('{"foo":"bar"}')
      response.json({ foo: 'bar' })
    end

    it 'sets the specified status and writes the JSON' do
      response.should_receive(:write_head).with(123).ordered
      response.should_receive(:write).with('{"foo":"bar"}')
      response.json(123, { foo: 'bar' })
    end

    it 'calls end' do
      response.should_receive(:end)
      response.json({ foo: 'bar' })
    end
  end

  describe '#jsonp' do
    let(:jsonp_response) do
      jsonp_response = response
      jsonp_response.stub(:params) { { 'callback' => 'foo' } }
      jsonp_response
    end

    it 'sets the type' do
      jsonp_response.should_receive(:type).with('application/javascript')
      jsonp_response.jsonp({ foo: 'bar' })
    end

    it 'writes the JSONP' do
      jsonp_response.should_receive(:write).with('foo({"foo":"bar"});')
      jsonp_response.jsonp({ foo: 'bar' })
    end

    it 'sets the specified status and writes the JSONP' do
      jsonp_response.should_receive(:write_head).with(123).ordered
      jsonp_response.should_receive(:write).with('foo({"foo":"bar"});')
      jsonp_response.jsonp(123, { foo: 'bar' })
    end

    it 'calls end' do
      jsonp_response.should_receive(:end)
      jsonp_response.jsonp({ foo: 'bar' })
    end

    it 'raises an error if the callback param is not present' do
      jsonp_response = response
      jsonp_response.should_receive(:write).with('{"foo":"bar"}')
      jsonp_response.jsonp({ foo: 'bar' })
    end

    it 'uses specified a callback name' do
      original = Expressr::App.settings['jsonp callback name']
      Expressr::App.settings['jsonp callback name'] = 'my_callback'
      response.stub(:params) { { 'my_callback' => 'baz' } }
      response.should_receive(:write).with('baz({"foo":"bar"});')
      response.jsonp({ foo: 'bar' })
      Expressr::App.settings['jsonp callback name'] = original
    end
  end

  describe '#type' do
    it 'sets the header' do
      response.should_receive(:set_header).with('Content-Type', 'foo')
      response.type('foo')
    end
  end

  describe '#format' do
    it 'calls the block if the type matches' do
      block = proc {}
      request = double
      request.stub(:accepts) { true }
      response.stub(:request) { request }
      block.should_receive(:call)
      response.format({ 'html' => block })
    end

    it 'calls the block if the type does not match' do
      block = proc {}
      request = double
      request.stub(:accepts) { false }
      response.stub(:request) { request }
      block.should_not_receive(:call)
      response.format({ 'html' => block })
    end
  end

  describe '#attachment' do
    it 'sets the headers' do
      response.should_receive(:set_header).with('Content-Type', 'image/png')
      response.should_receive(:set_header).with('Content-Disposition', 'attachment; filename="bar.png"')
      response.attachment('foo/bar.png')
    end
  end

  describe '#send_file' do
    it 'calls attachment with the path' do
      response.stub(:read_file) { 'baz' }
      response.should_receive(:attachment) do |path|
        path.should end_with 'foo/bar.png'
      end
      response.send_file('foo/bar.png')
    end

    it 'writes the file content' do
      response.stub(:read_file) { 'baz' }
      response.should_receive(:write).with('baz')
      response.send_file('foo/bar.png')
    end
  end

  describe '#download' do
    it 'calls attachment and send_file' do
      response.should_receive(:attachment).with('baz.png').ordered
      response.should_receive(:send_file).with('foo/bar.png', bypass_headers: true).ordered
      response.download('foo/bar.png', 'baz.png')
    end

    it 'calls attachment and send_file' do
      response.should_receive(:attachment).with('foo/bar.png').ordered
      response.should_receive(:send_file).with('foo/bar.png', bypass_headers: true).ordered
      response.download('foo/bar.png')
    end
  end

  describe '#links' do
    it 'sets the header' do
      response.should_receive(:set_header).with('Link', '<bar>; rel="foo", <baz>; rel="bar"')
      response.links({ foo: 'bar', bar: 'baz' })
    end
  end

  describe '#render' do
    it 'renders Slim with locals' do
      Expressr::App.settings['view engine'] = 'slim'
      response.should_receive(:out).with('<h4>bar</h4>')
      response.render('view', 'foo' => 'bar')
    end

    it 'renders Haml with locals' do
      Expressr::App.settings['view engine'] = 'haml'
      response.should_receive(:out).with("<h3>bar</h3>\n")
      response.render('view', 'foo' => 'bar')
    end
  end
end
