require 'sinatra'
require 'rack/cors'
require 'tilt/erubis'
require 'tilt/kramdown'
require 'mongoid'
require_relative 'models/metrics'
require 'rack/conneg'
require 'iso8601'
require 'dotenv'
require 'kramdown'
require 'exception_notification'

require_relative 'metrics-api/helpers'
require_relative 'metrics-api/date-wrangler'

Dotenv.load unless ENV['RACK_ENV'] == 'test'

Mongoid.load!(File.expand_path("../mongoid.yml", File.dirname(__FILE__)), ENV['RACK_ENV'])

Metric.create_indexes

class MetricsApi < Sinatra::Base

  # Disable JSON CSRF protection - this is a JSON API goddammit.
  set :protection, :except => [:json_csrf, :frame_options]

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

  helpers Helpers

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
    headers 'Vary' => 'Accept'

    if negotiated?
      content_type negotiated_type
    end
  end

  get '/' do
    redirect to '/metrics'
  end

  get '/documentation' do
    respond_to do |wants|

      wants.html do
        @config = config
        @title = 'Metrics API'
        erb :index, layout: 'layouts/default'.to_sym
      end

      wants.other { error_406 }
    end
  end

  get '/metrics' do
    @metrics = {
      metrics: Metric.all.distinct(:name).sort.map do |name|
        {
          name: name,
          url: "#{request.base_url}/metrics/#{name}.json"
        }
      end
    }

    @config = config

    respond_to do |wants|
      wants.json { @metrics.to_json }

      wants.html do
        @title = 'Metrics API'
        @created = Metric.first.time rescue DateTime.parse("2015-01-01T00:00:00Z")
        @updated = Metric.last.time rescue DateTime.parse("2016-01-01T00:00:00Z")
        erb :metrics, layout: 'layouts/default'.to_sym
      end

      wants.other { error_406 }
    end
  end

  post '/metrics/:metric' do
    protected!
    @metric = Metric.new(JSON.parse request.body.read)

    if @metric.save
      return 201
    else
      return 500
    end
  end

  get '/metrics/:metric/?' do
    @metric = Metric.where(name: params[:metric]).order_by(:time.asc).last
    respond_to do |wants|
      wants.json { @metric.to_json }

      wants.html do
        url = generate_url(@metric.name, request.params)
        redirect to url
      end

      wants.other { error_406 }
    end
  end

  get '/metrics/:metric/:time' do
    time = DateTime.parse(params[:time]) rescue
      error_400("'#{params[:time]}' is not a valid ISO8601 date/time.")

    @metric = Metric.where(name: params[:metric], :time.lte => time).order_by(:time.asc).last
    respond_to do |wants|
      wants.json { @metric.to_json }

      wants.html do
        @alternatives = [
          'chart',
          'number',
          'target',
          'tasklist',
          'pie'
        ]

        @layout = params.fetch('layout', 'rich')
        @type = params.fetch('type', 'chart')
        @boxcolour = "##{params.fetch('boxcolour', 'ddd')}"
        @textcolour = "##{params.fetch('textcolour', '222')}"
        @autorefresh = params.fetch('autorefresh', nil)

        @plotly_modebar = (@layout == 'rich')

        erb :metric, layout: "layouts/#{@layout}".to_sym
      end

      wants.other { error_406 }
    end
  end

  get '/metrics/:metric/:from/:to' do
    start_date = DateTime.parse(params[:from]) rescue nil
    end_date = DateTime.parse(params[:to]) rescue nil

    if params[:from].is_duration?
      start_date = get_start_date params rescue
        error_400("'#{params[:from]}' is not a valid ISO8601 duration.")
    end

    if params[:to].is_duration?
      end_date = get_end_date params rescue
        error_400("'#{params[:to]}' is not a valid ISO8601 duration.")
    end

    invalid = []

    invalid << "'#{params[:from]}' is not a valid ISO8601 date/time." if start_date.nil? && params[:from] != "*"
    invalid << "'#{params[:to]}' is not a valid ISO8601 date/time." if end_date.nil? && params[:to] != "*"

    error_400(invalid.join(" ")) unless invalid.blank?

    if start_date != nil && end_date != nil
      error_400("'from' date must be before 'to' date.") if start_date > end_date
    end

    metrics = Metric.where(:name => params[:metric])
    metrics = metrics.where(:time.gte => start_date) if start_date
    metrics = metrics.where(:time.lte => end_date) if end_date

    metrics = metrics.order_by(:time.asc)

    data = {
      :count => metrics.count,
      :values => []
    }

    data[:path] = metric_config(params[:metric])['value-path'] if params[:with_path]

    metrics.each do |metric|
      data[:values] << {
        :time => metric.time,
        :value => metric.value
      }
    end

    respond_to do |wants|
      wants.json { data.to_json }

      wants.html do
        @alternatives = [
          'chart',
          'number',
          'target'
        ]

        @layout = params.fetch('layout', 'rich')
        @type = params.fetch('type', 'chart')
        @boxcolour = "##{params.fetch('boxcolour', 'ddd')}"
        @textcolour = "##{params.fetch('textcolour', '222')}"
        @barcolour = "##{params.fetch('barcolour', 'fff')}"
        @autorefresh = params.fetch('autorefresh', nil)

        @plotly_modebar = (@layout == 'rich')

        erb :metric, layout: "layouts/#{@layout}".to_sym
      end

      wants.other { error_406 }
    end
  end

  get '/dashboards/:dashboard' do
    @title = "#{params[:dashboard]} dashboard".titleise
    @board = get_dashboard_data params[:dashboard]

    respond_to do |wants|
      wants.html do
        erb :dashboard, layout: :"layouts/dashboard"
      end
    end
  end

  def error_406
    content_type 'text/plain'
    error 406, "Not Acceptable"
  end

  def error_400(error)
    content_type 'text/plain'
    error 400, {:status => error}.to_json
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
