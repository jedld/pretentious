require 'rspec/core/rake_task'
require "bundler/gem_tasks"

RSpec::Core::RakeTask.new('spec')

# If you want to make this the default task
task :default => :spec
task :test => :spec

desc "Runs the minitest suite"
task :minitest do
  $: << './test'
  Dir.glob('./test/test_*.rb').each { |file| require file}
end