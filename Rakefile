require './lib/metrics-api'

desc "Purely for setting up metrics on the demo site"
namespace :demo do
  task :setup do
    Metric.all.delete
    MetricMetadata.all.delete

    5.times do |i|
      Metric.create(
        name: "simple-metric",
        time: DateTime.now - i,
        value: rand(100)
      )

      Metric.create(
        name: "metric-with-target",
        time: DateTime.now - i,
        value: {
          actual: rand(0..100),
          annual_target: rand(100..1000)
        }
      )

      MetricMetadata.create(
        name: "metric-with-target",
        type: "target"
      )

      Metric.create(
        name: "metric-with-ytd-target",
        time: DateTime.now - i,
        value: {
          actual: rand(0..100),
          annual_target: rand(100..500),
          ytd_target: rand(500..1000)
        }
      )

      MetricMetadata.create(
        name: "metric-with-ytd-target",
        type: "target"
      )

      Metric.create(
        name: "metric-with-multiple-values",
        time: DateTime.now - i,
        value: {
          total: {
            value1: rand(100),
            value2: rand(100),
            value3: rand(100),
            value4: rand(100),
          }
        }
      )

      MetricMetadata.create(
        name: "metric-with-multiple-values",
        type: "pie"
      )

    end
  end
end

unless ENV['RACK_ENV'] == 'production'
  require 'cucumber/rake/task'
  require 'rspec/core/rake_task'
  require 'coveralls/rake/task'

  Cucumber::Rake::Task.new
  RSpec::Core::RakeTask.new
  Coveralls::RakeTask.new

  require 'jasmine'
  load 'jasmine/tasks/jasmine.rake'

  task :default => [:cucumber, :spec, 'jasmine:ci', 'coveralls:push']
end
