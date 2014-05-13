require 'spec_helper'

describe Expressr::RouteItem do
  let(:proc_double) { proc{} }

      # request.stub(:env) { request_method: 'GET', request_uri: '/foo' }

  describe '#matches_request?' do
    it 'returns false for an unmatched content type' do
      request = double
      request.stub(:env) { { request_uri: '/foo' } }
      request.stub(:accepts) { false }
      item = described_class.new(proc_double, path: '/foo', content_type: 'bar')
      item.matches_request?(request).should be_false
    end

    it 'returns true for a matched content type' do
      request = double
      request.stub(:env) { { request_uri: '/foo' } }
      request.stub(:accepts) { true }
      item = described_class.new(proc_double, path: '/foo', content_type: 'bar')
      item.matches_request?(request).should be_true
    end

    it 'returns false for an unmatched method' do
      request = double
      request.stub(:env) { { request_uri: '/foo', request_method: 'GET' } }
      item = described_class.new(proc_double, path: '/foo', method: 'POST')
      item.matches_request?(request).should be_false
    end

    it 'returns true for a matched method' do
      request = double
      request.stub(:env) { { request_uri: '/foo', request_method: 'POST' } }
      item = described_class.new(proc_double, path: '/foo', method: 'POST')
      item.matches_request?(request).should be_true
    end

    it 'returns false for an unmatched path' do
      request = double
      request.stub(:env) { { request_uri: '/foo' } }
      item = described_class.new(proc_double, path: '/user/:user_id/comment/:comment_id')
      item.matches_request?(request).should be_false
    end

    it 'returns true for a matched path' do
      request = double
      request.stub(:env) { { request_uri: '/user/10/comment/11' } }
      item = described_class.new(proc_double, path: '/user/:user_id/comment/:comment_id')
      item.matches_request?(request).should be_true
    end

    it 'sets the params for a matched path with params' do
      request = double
      request.stub(:env) { { request_uri: '/user/10/comment/11' } }
      item = described_class.new(proc_double, path: '/user/:user_id/comment/:comment_id')
      item.matches_request?(request)
      item.params.should == {'user_id'=>'10', 'comment_id'=>'11'}
    end
    
    it 'returns false for an unmatched param' do
      request = double
      request.stub(:env) { { request_uri: '/foo' } }
      request.stub(:params) { { 'baz' => '1' } }
      item = described_class.new(proc_double, path: '/foo', param: 'bar')
      item.matches_request?(request).should be_false
    end

    it 'returns true for a matched param' do
      request = double
      request.stub(:env) { { request_uri: '/foo' } }
      request.stub(:params) { { 'bar' => 'baz' } }
      item = described_class.new(proc_double, path: '/foo', param: 'bar')
      item.matches_request?(request).should be_true
    end

    it 'adds the param value to additional_arguments for a matched param' do
      request = double
      request.stub(:env) { { request_uri: '/foo' } }
      request.stub(:params) { { 'bar' => 'baz' } }
      item = described_class.new(proc_double, path: '/foo', param: 'bar')
      item.matches_request?(request)
      item.additional_arguments.should == ['baz']
    end
  end
end
