require 'rubygems'
require 'bundler'
Bundler.setup

ENV['RACK_ENV'] ||= 'development'

require File.join(File.dirname(__FILE__), 'lib/bothan.rb')

use(Rack::Cors) do
  allow do
    origins '*'
    resource '*', :headers => :any, :methods => [:get]
  end
end

use Rack::MethodOverride

# run Bothan::App
run Rack::Cascade.new [Bothan::App]
