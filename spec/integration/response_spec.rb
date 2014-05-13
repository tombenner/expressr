require 'spec_helper'

describe Expressr::Response do
  include ServerIntegrationHelper

  describe '#redirect' do
    it 'writes a 302 and a Location header' do
      block = proc do |request, response|
        response.redirect('/foo')
      end
      app.router.use(&block)
      start_app(app)
      response = http_get
      response.code.should == '302'
      response.header['Location'].should == '/foo'
      stop_app(app)
    end

    it 'writes a custom status and a Location header' do
      block = proc do |request, response|
        response.redirect(303, '/foo')
      end
      app.router.use(&block)
      start_app(app)
      response = http_get
      response.code.should == '303'
      response.header['Location'].should == '/foo'
      stop_app(app)
    end
  end

  describe '#cookie' do
    it 'sets a cookie' do
      block = proc do |request, response|
        response.cookie('foo', 'bar')
        response.out
      end
      app.router.use(&block)
      start_app(app)
      response = http_get
      response.header['Set-Cookie'].should == 'foo=bar; path='
      stop_app(app)
    end

    it 'sets the cookie domain' do
      block = proc do |request, response|
        response.cookie('foo', 'bar', 'domain' => 'baz.com')
        response.out
      end
      app.router.use(&block)
      start_app(app)
      response = http_get
      response.header['Set-Cookie'].should == 'foo=bar; domain=baz.com; path='
      stop_app(app)
    end

    it 'sets the cookie expires' do
      block = proc do |request, response|
        response.cookie('foo', 'bar', 'expires' => Time.at(1234))
        response.out
      end
      app.router.use(&block)
      start_app(app)
      response = http_get
      response.header['Set-Cookie'].should == 'foo=bar; path=; expires=Thu, 01 Jan 1970 00:20:34 GMT'
      stop_app(app)
    end
  end

  describe '#attachment' do
    it 'sets the headers' do
      block = proc do |request, response|
        response.attachment('foo/bar.png')
        response.out
      end
      app.router.use(&block)
      start_app(app)
      response = http_get
      response.header['Content-Type'].should == 'image/png'
      response.header['Content-Disposition'].should == 'attachment; filename="bar.png"'
      stop_app(app)
    end
  end
end
