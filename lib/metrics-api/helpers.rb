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

  def get_settings(params, data)
    @layout = params.fetch('layout', 'rich')
    @type = params.fetch('type', visualisation_type(params[:metric], data))
    @boxcolour = "##{params.fetch('boxcolour', 'ddd')}"
    @textcolour = "##{params.fetch('textcolour', '222')}"
    @autorefresh = params.fetch('autorefresh', nil)

    @plotly_modebar = (@layout == 'rich')
  end

  def get_start_date params
    DateTime.parse(params[:to]) - params[:from].to_seconds
  end

  def get_end_date params
    DateTime.parse(params[:from]) + params[:to].to_seconds
  end

  def metrics_config
    @metrics_config ||= YAML.load File.read('config/metrics.yml')
  end

  def metric_config(metric)
    metrics_config[metric] || {}
  end

  def metric_defaults(metric)
    metric_config(metric)['defaults'] || {}
  end

  def generate_url(metric, params)
    defaults = metric_defaults(metric)
    url = datetime_path(defaults.delete('datetime'), metric)
    params.merge!(defaults)
    build_url(url, params.to_query)
  end

  def build_url(url, params)
    params = params.empty? ? nil : params
    [url, params].compact.join('?')
  end

  def datetime_path(datetime, metric)
    now = Time.now.iso8601
    if datetime == 'single'
      "/metrics/#{metric}/#{now}"
    else
      days = 30
      before = (Time.now - (60 * 60 * 24 * days)).iso8601
      "/metrics/#{metric}/#{before}/#{now}"
    end
  end

  def config
    {
      title: ENV['METRICS_API_TITLE'],
      description: ENV['METRICS_API_DESCRIPTION'],
      license: {
        name: ENV['METRICS_API_LICENSE_NAME'],
        url: ENV['METRICS_API_LICENSE_URL'],
        image: license_image(ENV['METRICS_API_LICENSE_URL'])
      },
      publisher: {
        name: ENV['METRICS_API_PUBLISHER_NAME'],
        url: ENV['METRICS_API_PUBLISHER_URL']
      },
      certificate_url: ENV['METRICS_API_CERTIFICATE_URL']
    }
  end

  def license_image(url)
    match = url.match /https?:\/\/creativecommons.org\/licenses\/([a-z\-]+)\/([0-9\.]+)/
    if match
      "https://licensebuttons.net/l/#{match[1]}/#{match[2]}/88x31.png"
    else
      nil
    end
  end

  def visualisation_type(metric_name, data)
    default = MetricDefault.where(name: metric_name).first
    if default.nil?
      guess_type(data)
    else
      default.type
    end
  end

  def guess_type(data)
    if data.nil?
      'chart'
    elsif data[:value].class == String
      'chart'
    elsif data[:value].class == Array && !data[:value].first[:progress].nil?
      'tasklist'
    elsif data[:value].class == Hash && !data[:value][:annual_target].nil?
      'target'
    elsif data[:value].class == Hash && Hash[*data[:value].first].class == Hash
      'pie'
    else
      'chart'
    end
  end

end

class String
  def titleise
    self.split(' ').map { |w| "#{w[0].upcase}#{w[1..-1]}" }.join ' '
  end

  def is_duration?
    return true if self =~ /^P/
    false
  end

  def to_seconds
    ISO8601::Duration.new(self).to_seconds.seconds
  end
end
