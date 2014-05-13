require 'spec_helper'

describe Expressr::RouteNode do
  let(:proc_double) { proc{} }
  let(:node_double) do
    node = double
    node.stub(:call)
    node
  end

  describe '#call' do
    it 'only continues once' do
      node = described_class.new(proc_double, node_double)
      node.should_receive(:continue).once.and_call_original
      node.call(double, double)
      node.call(double, double)
    end

    it 'calls the next node with the request and response' do
      next_node = node_double
      request = double
      response = double
      node = described_class.new(proc_double, next_node)
      next_node.should_receive(:call).with(request, response)
      node.call(request, response)
    end

    it 'calls the next node with additional arguments' do
      next_node = node_double
      request = double
      response = double
      additional_arguments = [double, double]
      node = described_class.new(proc_double, next_node, additional_arguments: additional_arguments)
      next_node.should_receive(:call).with(request, response, *additional_arguments)
      node.call(request, response)
    end
  end
end
