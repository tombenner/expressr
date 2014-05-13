require File.expand_path('../lib/expressr/version', __FILE__)

Gem::Specification.new do |s|
  s.authors       = ['Tom Benner']
  s.email         = ['tombenner@gmail.com']
  s.description = s.summary = %q{Express.js for Ruby}
  s.homepage      = 'https://github.com/tombenner/expressr'

  s.files         = Dir['lib/**/*'] + ['MIT-LICENSE', 'README.md']
  s.name          = 'expressr'
  s.require_paths = ['lib']
  s.version       = Expressr::VERSION
  s.license       = 'MIT'

  s.add_dependency 'noder'
  s.add_dependency 'hashie'
  s.add_dependency 'mime-types'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'haml'
  s.add_development_dependency 'slim'
end
