module Helpers
  def protected!
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
    halt 401, "Not authorized\n"
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == [ENV['METRICS_API_USERNAME'], ENV['METRICS_API_PASSWORD']]
  end

  def get_dashboard_data board, yaml = 'config/dashboards.yml'
    defaults = YAML.load_file('config/defaults.yml')['dashboards']
    data = YAML.load_file(yaml)[board]

    data.map { |d| defaults.merge d }
  end

  def query_string hash
    qs = []
    hash.each_pair do |key, value|
      qs.push "#{key}=#{value}" unless key == 'metric'
    end

    qs.join '&'
  end

  def extract_title url
    regex = /http.*metrics\/([^\/]*)[\/|\.].*/
    result = url.match(regex)
    words = result[1].split('-')
    words.map { |word|
      word[0].upcase + word[1..-1].downcase
    }.join(' ')
  end

  def metrics_config
    @metrics_config ||= YAML.load File.read('config/metrics.yml')
  end

  def metric_config(metric)
    metrics_config[metric] || {}
  end

  def generate_url(metric, request)
    config = metric_config(metric)
    now = Time.now.iso8601
    if config['default-datetime'] == 'single'
      "/metrics/#{metric}/#{now}?#{request.query_string}"
    else
      days = 30
      before = (Time.now - (60 * 60 * 24 * days)).iso8601
      "/metrics/#{metric}/#{before}/#{now}?#{request.query_string}"
    end
  end
end

class String
  def titleise
    self.split(' ').map { |w| "#{w[0].upcase}#{w[1..-1]}" }.join ' '
  end
end
