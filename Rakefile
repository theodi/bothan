require 'cucumber/rake/task'

Cucumber::Rake::Task.new
require 'jasmine'
load 'jasmine/tasks/jasmine.rake'

task :default => [:cucumber, 'jasmine:ci']
