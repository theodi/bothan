$:.unshift File.dirname(__FILE__)

require 'byebug'
require 'sinatra'
require 'rack/cors'
require 'tilt/erb'
require 'tilt/kramdown'

require 'rack/conneg'
require 'iso8601'
require 'dotenv'
require 'kramdown'

module Bothan
end

# require 'bothan/api'
require 'bothan/metrics'
require 'bothan/dashboards'

require 'action_view'
require 'github/markup'

require 'bothan/extensions/string'

require 'bothan/helpers/app_helpers'
require 'bothan/helpers/auth_helpers'
require 'bothan/helpers/metrics_helpers'
require 'bothan/helpers/views_helpers'
require 'bothan/helpers/dashboard_helpers'

Dotenv.load unless ENV['RACK_ENV'] == 'test'

class Bothan::App < Sinatra::Base
  helpers Bothan::Helpers::App, Bothan::Helpers::Auth, Bothan::Helpers::Metrics, Bothan::Helpers::Views, Bothan::Helpers::Dashboard

  # Disable JSON CSRF protection - this is a JSON API goddammit.
  set :protection, :except => [:json_csrf, :frame_options]

  set :views, Proc.new { File.join(root, "..", "views") }
  set :public_folder, Proc.new { File.join(root, "..", "public") }

  use Rack::Conneg do |conneg|
    conneg.set :accept_all_extensions, false
    conneg.set :fallback, :html
    conneg.ignore_contents_of 'lib/public'
    conneg.provide [
         :html
     ]
  end

  before do
    @config = config

    # If the client wants something we can't provide (i.e. JSON) then throw a 406
    if request.negotiated?
      unless [nil, "", ".html"].include?(request.negotiated_ext)
        error_406
      end
      accept = request.accept.map(&:to_s)
      if accept!=["*/*"] && !accept.include?(request.negotiated_type)
        error_406
      end
    end

    content_type 'text/html'
    headers 'Content-Type' => "text/html;charset=utf-8"
  end

  register Bothan::Api
  register Bothan::Metrics
  register Bothan::Dashboards

  get '/' do
    redirect to "#{request.scheme}://#{request.host_with_port}/metrics"
  end

  get '/login' do
    protected!

    redirect to "#{request.scheme}://#{request.host_with_port}/metrics"
  end

  get '/documentation' do
    respond_to do |wants|

      wants.html do
        @title = 'Metrics API'
        @markup = GitHub::Markup.render('api.md', File.read('docs/api.md').gsub(/---.+---/m,' ')).html_safe
        erb :index, layout: 'layouts/default'.to_sym
      end

      wants.other { error_406 }
    end
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
