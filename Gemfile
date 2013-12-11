source 'https://rubygems.org'

#ruby=ruby-1.9.3
ruby '1.9.3'
#ruby-gemset=metrics-api

gem 'sinatra'
gem 'dotenv'
gem 'thin'
gem 'haml'
gem 'kramdown'
gem 'foreman'
gem 'mongoid', '~> 3.0.0'
gem 'rack-conneg'
gem 'iso8601'

group :test do
  gem 'capybara-webkit'
  gem 'cucumber'
  gem 'cucumber-sinatra'
  gem 'rspec'
  gem 'rack-test'
  gem 'guard'
  gem 'guard-rspec', require: false
  gem 'guard-cucumber'
  gem 'terminal-notifier-guard'
  gem 'coveralls', require: false
  gem 'cucumber-api-steps', require: false, github: 'theodi/cucumber-api-steps', branch: 'feature-test-content-type'
  gem 'database_cleaner'
end
