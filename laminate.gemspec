$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'laminate/version'

Gem::Specification.new do |s|
  s.name     = 'laminate'
  s.version  = ::Laminate::VERSION
  s.authors  = ['Cameron Dutro']
  s.email    = ['camertron@gmail.com']
  s.homepage = 'https://github.com/camertron/laminate'

  s.description = s.summary = 'Turn any Ruby module into a composable decorator.'

  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true

  s.require_path = 'lib'
  s.files = Dir['{lib,spec}/**/*', 'README.md', 'laminate.gemspec', 'LICENSE']
end
