# Generated by cucumber-sinatra. (2013-12-03 12:11:29 +0000)

require 'coveralls'
Coveralls.wear_merged!

require 'dotenv'
Dotenv.load

ENV['RACK_ENV'] = 'test'
ENV['METRICS_API_USERNAME'] = 'foo'
ENV['METRICS_API_PASSWORD'] = 'bar'

require File.join(File.dirname(__FILE__), '..', '..', 'lib/bothan.rb')
require File.join(File.dirname(__FILE__), '..', '..', 'lib/api.rb')

require 'capybara'
require 'capybara/cucumber'
require 'rspec'
require 'cucumber/api_steps'
require 'cucumber/rspec/doubles'
require 'database_cleaner'
require 'database_cleaner/cucumber'
require 'timecop'

DatabaseCleaner.strategy = :truncation

Capybara.app = Rack::Cascade.new [ Bothan::App, Bothan::Api], [406]

class Bothan::AppWorld
  include Capybara::DSL
  include RSpec::Expectations
  include RSpec::Matchers

  def app
    Rack::Cascade.new [ Bothan::App, Bothan::Api], [406]
  end
end

World do
  Bothan::AppWorld.new
end
