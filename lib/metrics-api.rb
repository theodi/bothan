require 'sinatra/base'
require 'haml'
require 'mongoid'
require_relative 'models/metrics'

Mongoid.load!(File.expand_path("../mongoid.yml", File.dirname(__FILE__)), ENV['RACK_ENV'])

class MetricsApi < Sinatra::Base
  get '/' do
    haml :index, :locals => {
        :title           => 'Metrics API',
        :text            => 'Metrics API',
#        :bootstrap_theme => '../lavish-bootstrap.css'
    }
  end
  
  post '/metrics/:metric' do
    content_type :json
    
    @metric = Metric.new(params[:body])
    
    if @metric.save
      return 201
    else
      return 500
    end
  end

  get '/metrics/:metric' do
    content_type :json
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end


