require 'spec_helper'

describe Expressr::Renderer do
  describe '.get_renderer' do
    it 'returns a renderer' do
      described_class.get_renderer.should be_a(Expressr::Renderers::Base)
    end
  end

  it 'returns a Haml renderer' do
    Expressr::App.settings['view engine'] = 'haml'
    described_class.get_renderer.should be_a(Expressr::Renderers::Haml)
  end

  it 'returns a Slim renderer' do
    Expressr::App.settings['view engine'] = 'slim'
    described_class.get_renderer.should be_a(Expressr::Renderers::Slim)
  end
end
