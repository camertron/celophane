$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'celophane/version'

Gem::Specification.new do |s|
  s.name     = 'celophane'
  s.version  = ::Celophane::VERSION
  s.authors  = ['Cameron Dutro']
  s.email    = ['camertron@gmail.com']
  s.homepage = 'https://github.com/camertron/celophane'

  s.description = s.summary = 'Turn any Ruby module into a composable decorator.'

  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true

  s.require_path = 'lib'
  s.files = Dir['{lib,spec}/**/*', 'README.md', 'celophane.gemspec', 'LICENSE']
end
