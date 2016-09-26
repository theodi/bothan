require 'rubygems'
require 'bundler'
Bundler.setup

ENV['RACK_ENV'] ||= 'development'

require File.join(File.dirname(__FILE__), 'lib/metrics-api.rb')

use(Rack::Cors) do
  allow do
    origins '*'
    resource '*', :headers => :any, :methods => [:get]
  end
end

use Rack::MethodOverride

run MetricsApi
