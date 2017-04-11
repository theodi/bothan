$:.unshift File.dirname(__FILE__)

require 'sinatra'
require 'rack/cors'
require 'tilt/erubis'
require 'tilt/kramdown'

require 'rack/conneg'
require 'iso8601'
require 'dotenv'
require 'kramdown'
require 'exception_notification'

module Bothan
end

# require 'bothan/api'
require 'bothan/metrics'
require 'bothan/dashboards'
require 'action_view'
require 'github/markdown'

require 'bothan/helpers/app_helpers'
require 'bothan/helpers/auth_helpers'
require 'bothan/helpers/metrics_helpers'
require 'bothan/helpers/views_helpers'

Dotenv.load unless ENV['RACK_ENV'] == 'test'



module Bothan # - doesn't appear to matter if this is done or not
class App < Sinatra::Base
  helpers Bothan::Helpers::App, Bothan::Helpers::Auth, Bothan::Helpers::Metrics, Bothan::Helpers::Views

  # Disable JSON CSRF protection - this is a JSON API goddammit.
  set :protection, :except => [:json_csrf, :frame_options]

  set :views, Proc.new { File.join(root, "views") }
  set :public_folder, Proc.new { File.join(root, "public") }

  use ExceptionNotification::Rack,
      :email => {
          :email_prefix => "[Metrics API] ",
          :sender_address => %{"errors" <errors@metrics.theodi.org>},
          :exception_recipients => %w{ops@theodi.org},
          :smtp_settings => {
              :user_name => ENV["MANDRILL_USERNAME"],
              :password => ENV["MANDRILL_PASSWORD"],
              :domain => "theodi.org",
              :address => "smtp.mandrillapp.com",
              :port => 587,
              :authentication => :plain,
              :enable_starttls_auto => true
          }
      }

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

  # register Bothan::Api # API is no longer an extension to sinatra
  register Bothan::Metrics
  register Bothan::Dashboards

  get '/' do

    redirect to "#{request.scheme}://#{request.host_with_port}/metrics"
    # TODO - JSON from metrics endpoint to be captured and included via ERB
    # this function is a redirect to metric.rb lines 6-21
  end

  get '/login' do
    protected!

    redirect to "#{request.scheme}://#{request.host_with_port}/metrics"
    # TODO keep up to date with above per DRY
  end

  get '/documentation' do

      @title = 'Metrics API'
      @markup = GitHub::Markdown.render_gfm(File.read('docs/api.md').gsub(/---.+---/m,' '))
      erb :index, layout: 'layouts/default'.to_sym

  end

  # start the server if ruby file executed directly - now loaded by RACK CASCADE
  # run! if app_file == $0
end
end