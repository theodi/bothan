require 'sinatra'
require 'haml'
require 'mongoid'
require_relative 'models/metrics'
require 'rack/conneg'
require 'iso8601'

Mongoid.load!(File.expand_path("../mongoid.yml", File.dirname(__FILE__)), ENV['RACK_ENV'])

class MetricsApi < Sinatra::Base

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
      "metrics" => Metric.all.distinct(:name).map do |name|
        {
          name: name,
          url: "#{request.scheme}://#{request.host}/metrics/#{name}.json"
        }
      end
    }
    respond_to do |wants|
      wants.json { data.to_json }
      wants.other { error_406 }
    end
  end
  
  post '/metrics/:metric' do
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

  # start the server if ruby file executed directly
  run! if app_file == $0
end


