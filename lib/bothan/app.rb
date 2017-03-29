$:.unshift File.dirname(__FILE__)

require 'action_view'
require 'glorify'
require 'github/markup'

require 'extensions/string'

require 'helpers/app_helpers'
require 'helpers/auth_helpers'
require 'helpers/metrics_helpers'
require 'helpers/views_helpers'

class Bothan::App < Sinatra::Base
  helpers Bothan::Helpers::App, Bothan::Helpers::Auth, Bothan::Helpers::Metrics, Bothan::Helpers::Views

  # Disable JSON CSRF protection - this is a JSON API goddammit.
  set :protection, :except => [:json_csrf, :frame_options]

  set :views, Proc.new { File.join(root, "..", "views") }
  set :public_folder, Proc.new { File.join(root, "..", "public") }

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
      :json,
      :html
    ]
  end

  before do
    @config = config

    headers 'Vary' => 'Accept'

    if negotiated?
      content_type negotiated_type
    end
  end

  register Bothan::Api
  register Bothan::Metrics
  register Bothan::Dashboards
  register Sinatra::Glorify
  register GitHub::Markup

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
        @docs = File.open('docs/api.md').read
        erb :index, layout: 'layouts/default'.to_sym
      end

      wants.other { error_406 }
    end
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
