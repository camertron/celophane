require 'rspec/core/rake_task'
require 'rubygems/package_task'
require './lib/laminate'

Bundler::GemHelper.install_tasks

desc 'Run specs'
RSpec::Core::RakeTask.new do |t|
  t.pattern = './spec/**/*_spec.rb'
end

task default: :spec
