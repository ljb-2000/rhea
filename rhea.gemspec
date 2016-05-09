require File.expand_path('../lib/rhea/version', __FILE__)

Gem::Specification.new do |s|
  s.authors       = ['Tom Benner']
  s.email         = ['tombenner@gmail.com']
  s.description = s.summary = %q{A web UI for managing a Kubernetes cluster}
  s.homepage      = 'https://github.com/entelo/rhea'

  s.files         = `git ls-files`.split($\)
  s.name          = 'rhea'
  s.require_paths = ['lib']
  s.version       = Rhea::VERSION
  s.license       = 'MIT'

  s.add_dependency 'kubeclient', '~> 0.3.0'
  s.add_dependency 'haml', '~> 4.0'
  s.add_dependency 'kaminari', '~> 0.16'
  s.add_dependency 'sass-rails', '~> 5.0'

  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'rspec-rails', '~> 3.0'
  s.add_development_dependency 'vcr', '~> 2.9'
  s.add_development_dependency 'webmock', '~> 1.8'
end
