require 'cucumber/rake/task'
require 'rspec/core/rake_task'
require 'coveralls/rake/task'

Cucumber::Rake::Task.new
RSpec::Core::RakeTask.new
Coveralls::RakeTask.new

require 'jasmine'
load 'jasmine/tasks/jasmine.rake'

task :default => [:cucumber, :spec, 'jasmine:ci', 'coveralls:push']
