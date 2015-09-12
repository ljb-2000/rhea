require File.expand_path('../lib/rhea/version', __FILE__)

Gem::Specification.new do |s|
  s.authors       = ['Tom Benner']
  s.email         = ['tombenner@gmail.com']
  s.description = s.summary = %q{Distributed workers}
  s.homepage      = 'https://github.com/EnteloEngineering/rhea'

  s.files         = `git ls-files`.split($\)
  s.name          = 'rhea'
  s.require_paths = ['lib']
  s.version       = Rhea::VERSION
  s.license       = 'MIT'

  s.add_dependency 'kubeclient', '~> 0.3.0'
  s.add_dependency 'coffee-rails'
  s.add_dependency 'haml'
  s.add_dependency 'sass-rails'

  s.add_development_dependency 'rspec'
end
