require 'spec_helper'

describe Expressr::Request do
  let(:connection_double) do
    connection = double
    connection.stub(:[])
    connection
  end
  let(:request) { described_class.new(connection_double) }

  describe '#param' do
    it 'returns the param' do
      request.stub(:params) { { 'foo' => 'bar' } }
      request.param('foo').should == 'bar'
    end
  end

  describe '#get' do
    it 'returns the header' do
      request.stub(:headers) { { 'foo' => 'bar' } }
      request.get('foo').should == 'bar'
    end
  end

  describe '#accepts' do
    it 'returns the first type' do
      request.stub(:headers) { { 'Accept' => 'foo,bar' } }
      request.accepts(['bar']).should == 'bar'
    end

    it 'returns nil if there are no matches' do
      request.stub(:headers) { { 'Accept' => 'foo,baz' } }
      request.accepts(['bar']).should == nil
    end

    it 'receives a string' do
      request.stub(:headers) { { 'Accept' => 'foo,bar' } }
      request.accepts('bar').should == 'bar'
    end
  end

  describe '#is?' do
    it 'returns true if the type is present' do
      request.stub(:headers) { { 'Content-Type' => 'foo; bar' } }
      request.is?('bar').should be_true
    end

    it 'returns false if the type is absent' do
      request.stub(:headers) { { 'Content-Type' => 'foo; bar' } }
      request.is?('baz').should be_false
    end

    it 'returns false if the type header is not present' do
      request.stub(:headers) { {} }
      request.is?('foo').should be_false
    end
  end

  describe '#host' do
    it 'returns the host' do
      request.stub(:headers) { { 'Host' => 'foo.com' } }
      request.host.should == 'foo.com'
    end

    it 'removes the port' do
      request.stub(:headers) { { 'Host' => 'foo.com:80' } }
      request.host.should == 'foo.com'
    end
  end

  describe '#xhr?' do
    it 'returns true if it is an XHR request' do
      request.stub(:headers) { { 'X-Requested-With' => 'XMLHttpRequest' } }
      request.xhr?.should be_true
    end

    it 'returns false if it is not an XHR request' do
      request.stub(:headers) { { 'X-Requested-With' => 'foo' } }
      request.xhr?.should be_false
    end
  end

  describe '#subdomains' do
    it 'returns the subdomains' do
      request.stub(:headers) { { 'Host' => 'foo.bar.baz.com' } }
      request.subdomains.should == ['bar', 'foo']
    end

    it 'returns an empty array if there are no subdomains' do
      request.stub(:headers) { { 'Host' => 'foo.com' } }
      request.subdomains.should == []
    end
  end

  describe '#locals' do
    it 'allows locals to be set using dots' do
      request.locals.foo = :bar
      request.locals.foo.should == :bar
    end
  end
end
