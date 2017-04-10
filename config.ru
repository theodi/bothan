require 'rubygems'
require 'bundler'
require 'pry'
Bundler.setup

ENV['RACK_ENV'] ||= 'development'

require File.join(File.dirname(__FILE__), 'lib/bothan.rb')
require File.join(File.dirname(__FILE__), 'lib/api.rb')

use(Rack::Cors) do
  allow do
    origins '*'
    resource '*', :headers => :any, :methods => [:get]
  end
end

use Rack::MethodOverride
use Rack::Session::Cookie
run Rack::Cascade.new [Bothan::Api, Bothan::App] # changed order "fixes" sinatra app not rendering
