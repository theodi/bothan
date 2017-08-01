$:.unshift File.dirname(__FILE__)

require 'sinatra'
require 'rack/cors'
require 'tilt/erubis'
require 'tilt/kramdown'
require 'mongoid'
require 'rack/conneg'
require 'iso8601'
require 'dotenv'
require 'kramdown'
require 'pusher'

module Bothan
end

require 'models/metrics'
require 'models/metadata'
require 'models/dashboard'

require 'bothan/api'
require 'bothan/metrics'
require 'bothan/dashboards'
require 'bothan/app'

Dotenv.load unless ENV['RACK_ENV'] == 'test'

Mongoid.load!(File.expand_path("../mongoid.yml", File.dirname(__FILE__)), ENV['RACK_ENV'])

Metric.create_indexes
