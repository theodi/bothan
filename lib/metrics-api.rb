require 'sinatra/base'
require 'haml'

class MetricsApi < Sinatra::Base
  get '/' do
    haml :index, :locals => {
        :title           => 'Metrics API',
        :text            => 'Metrics API',
#        :bootstrap_theme => '../lavish-bootstrap.css'
    }
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end


