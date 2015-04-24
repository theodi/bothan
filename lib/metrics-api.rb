require 'sinatra'
require 'rack/cors'
require 'haml'
require 'mongoid'
require_relative 'models/metrics'
require 'rack/conneg'
require 'iso8601'
require 'dotenv'
require 'kramdown'

Dotenv.load unless ENV['RACK_ENV'] == 'test'

Mongoid.load!(File.expand_path("../mongoid.yml", File.dirname(__FILE__)), ENV['RACK_ENV'])

class MetricsApi < Sinatra::Base

  # Disable JSON CSRF protection - this is a JSON API goddammit.
  set :protection, :except => [:json_csrf]

  helpers do
    def protected!
      return if authorized?
      headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
      halt 401, "Not authorized\n"
    end

    def authorized?
      @auth ||=  Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == [ENV['METRICS_API_USERNAME'], ENV['METRICS_API_PASSWORD']]
    end
  end

  use(Rack::Conneg) { |conneg|
    conneg.set :accept_all_extensions, false
    conneg.set :fallback, :html
    conneg.provide([:json])
  }

  before do
    if negotiated?
      content_type negotiated_type
    end
  end

  get '/' do
    respond_to do |wants|
      wants.html {
        haml :index, :locals => {
            :title           => 'Metrics API',
            :text            => 'Metrics API',
    #        :bootstrap_theme => '../lavish-bootstrap.css'
        }
      }
      wants.other { error_406 }
    end
  end

  get '/metrics' do
    data =     {
      "metrics" => Metric.all.distinct(:name).sort.map do |name|
        {
          name: name,
          url: "https://#{request.host}/metrics/#{name}.json"
        }
      end
    }
    respond_to do |wants|
      wants.json { data.to_json }
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

  get '/metrics/:metric' do
    @metric = Metric.where(name: params[:metric]).order_by(:time.asc).last
    respond_to do |wants|
      wants.json { @metric.to_json }
      wants.other { error_406 }
    end
  end

  get '/metrics/:metric/:time' do
    time = DateTime.parse(params[:time]) rescue error_400("'#{params[:time]}' is not a valid ISO8601 date/time.")
    @metric = Metric.where(name: params[:metric], :time.lte => time).order_by(:time.asc).last
    respond_to do |wants|
      wants.json { @metric.to_json }
      wants.other { error_406 }
    end
  end

  get '/metrics/:metric/:from/:to' do
    start_date = DateTime.parse(params[:from]) rescue nil
    end_date = DateTime.parse(params[:to]) rescue nil

    if params[:from] =~ /^P/
      start_date = end_date - ISO8601::Duration.new(params[:from]).to_seconds.seconds rescue error_400("'#{params[:from]}' is not a valid ISO8601 duration.")
    end

    if params[:to] =~ /^P/
      end_date = start_date + ISO8601::Duration.new(params[:to]).to_seconds.seconds rescue error_400("'#{params[:to]}' is not a valid ISO8601 duration.")
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

    metrics.each do |metric|
      data[:values] << {
        :time => metric.time,
        :value => metric.value
      }
    end

    respond_to do |wants|
      wants.json { data.to_json }
      wants.other { error_406 }
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
