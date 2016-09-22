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

  get '/login' do
    protected!

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

    body = JSON.parse request.body.read

    @metric = Metric.new({
      "name" => params[:metric].parameterize,
      "time" => body["time"],
      "value" => body["value"]
    })

    metadata = MetricMetadata.find_or_create_by(name: params[:metric].parameterize)

    if metadata.title.blank?
      metadata.title[:en] = params[:metric]
      metadata.save
    end

    if @metric.save
      return 201
    else
      return 500
    end
  end

  get '/metrics/:metric/metadata' do
    protected!

    @metric = Metric.find_by(name: params[:metric].parameterize)
    @metadata = MetricMetadata.find_or_initialize_by(name: params[:metric].parameterize)
    @allowed_datatypes = MetricMetadata.validators.find { |v| v.attributes == [:datatype] }.send(:delimiter)

    @alternatives = get_alternatives(@metric.value)

    respond_to do |wants|

      wants.html do
        @config = config
        @title = {
          'en' => 'Metadata'
        }
        erb :metadata, layout: 'layouts/default'.to_sym
      end
    end
  end

  post '/metrics/:metric/metadata' do
    protected!
    begin
      data = JSON.parse request.body.read
      @meta = MetricMetadata.find_or_create_by(name: params[:metric].parameterize)
      @meta.type = data["type"].presence
      @meta.datatype = data["datatype"].presence
      @meta.title.merge!(data["title"] || {})
      @meta.description.merge!(data["description"] || {})
      if @meta.save
        return 201
      else
        return 400
      end
    rescue
      return 500
    end
  end

  get '/metrics/:metric/?' do
    @metric = Metric.where(name: params[:metric].parameterize).order_by(:time.asc).last
    respond_to do |wants|
      wants.json { @metric.to_json }

      wants.html do
        url = generate_url(@metric, keep_params(request.params))

        redirect to url
      end

      wants.other { error_406 }
    end
  end

  get '/metrics/:metric/:time' do
    date_redirect(params)

    time = params[:time].to_datetime rescue
      error_400("'#{params[:time]}' is not a valid ISO8601 date/time.")

    metrics = Metric.where(name: params[:metric].parameterize, :time.lte => time).order_by(:time.asc)
    metric = metrics.last

    if params['default-dates'].present?
      url = generate_url(metric, keep_params(params))
      redirect to url
    end

    @metric = (metric.nil? ? {} : metric).to_json

    @date = time.to_s
    @earliest_date = metrics.first.time rescue nil

    respond_to do |wants|
      wants.json { @metric }

      wants.html do
        metric = JSON.parse(@metric, {:symbolize_names => true})
        @alternatives = get_alternatives(metric[:value])

        get_settings(params, metric)
        erb :metric, layout: "layouts/#{@layout}".to_sym
      end

      wants.other { error_406 }
    end
  end

  get '/metrics/:metric/:from/:to' do
    date_redirect(params)

    @from = params[:from]
    @to = params[:to]

    dates = DateWrangler.new @from, @to

    error_400 dates.errors.join ' ' if dates.errors

    metrics = Metric.where(:name => params[:metric].parameterize).asc(:time)

    if params['default-dates'].present?
      url = generate_url(metrics.first, keep_params(params))
      redirect to url
    end

    @earliest_date = metrics.first.time
    @latest_date = metrics.last.time

    metrics = metrics.where(:time.gte => dates.from) if dates.from
    metrics = metrics.where(:time.lte => dates.to) if dates.to

    metrics = metrics.order_by(:time.asc)

    data = {
      :count => metrics.count,
      :values => []
    }

    metrics.each do |metric|
      data[:values] << {
        :time => metric.time,
        :value => metric.value
      }
    end

    respond_to do |wants|
      wants.json { data.to_json }

      wants.html do
        value = data[:values].first
        @alternatives = get_alternatives(value[:value])

        get_settings(params, value)

        erb :metric, layout: "layouts/#{@layout}".to_sym
      end

      wants.other { error_406 }
    end
  end

  get '/dashboards/new' do
    @title = 'Create Dashboard'
    @metrics = Metric.all.distinct(:name).map { |m| Metric.find_by(name: m) }

    erb :'dashboards/new', layout: :'layouts/full-width'
  end

  get '/dashboards/:dashboard' do
    @dashboard = Dashboard.find_by(slug: params[:dashboard])
    @title = @dashboard.name

    respond_to do |wants|
      wants.html do
        erb :dashboard, layout: :"layouts/dashboard"
      end
    end
  end

  post '/dashboards' do
    slug = params[:dashboard][:name].parameterize
    params[:dashboard][:slug] = slug
    dashboard = Dashboard.create(params[:dashboard])

    redirect "/dashboards/#{slug}"
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
