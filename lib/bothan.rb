require 'sinatra'
require 'rack/cors'
require 'tilt/erubis'
require 'tilt/kramdown'
require 'mongoid'
require_relative 'models/metrics'
require_relative 'models/metadata'
require_relative 'models/dashboard'
require 'rack/conneg'
require 'iso8601'
require 'dotenv'
require 'kramdown'
require 'exception_notification'
require 'pusher'

module Bothan
end

require_relative 'bothan/helpers/helpers'
require_relative 'bothan/helpers/date-wrangler'
require_relative 'bothan/api'
require_relative 'bothan/dashboards'
require_relative 'bothan/app'

Dotenv.load unless ENV['RACK_ENV'] == 'test'

Mongoid.load!(File.expand_path("../mongoid.yml", File.dirname(__FILE__)), ENV['RACK_ENV'])

Metric.create_indexes
