require 'coveralls'
Coveralls.wear_merged!

ENV['RACK_ENV'] = 'test'

require 'bothan'
require 'data_kitten'
require 'rack/test'
require 'webmock/rspec'
require 'database_cleaner'
require 'nokogiri'
require 'byebug'
require 'dotenv'
Dotenv.load

module RSpecMixin
  include Rack::Test::Methods
  def app
    Bothan::App
  end
end

RSpec.configure do |config|
  config.include RSpecMixin

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  config.order = :random
  Kernel.srand config.seed
end
