class Bothan::App < Sinatra::Base

  # Disable JSON CSRF protection - this is a JSON API goddammit.
  set :protection, :except => [:json_csrf, :frame_options]

  set :views, Proc.new { File.join(root, "..", "views") }

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
    @config = config

    headers 'Vary' => 'Accept'

    if negotiated?
      content_type negotiated_type
    end
  end

  register Bothan::Api
  register Bothan::Dashboards

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

  get '/metrics/:metric/metadata' do
    protected!

    @metric = Metric.find_by(name: params[:metric].parameterize)
    @metadata = MetricMetadata.find_or_initialize_by(name: params[:metric].parameterize)
    @allowed_datatypes = MetricMetadata.validators.find { |v| v.attributes == [:datatype] }.send(:delimiter)

    @alternatives = get_alternatives(@metric.value)

    respond_to do |wants|

      wants.html do
        @title = {
          'en' => 'Metadata'
        }
        erb :metadata, layout: 'layouts/default'.to_sym
      end
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

  get '/metrics/:metric/all' do
    params[:from] = '*'
    params[:to] = '*'
    get_metric_range(params)
  end

  get '/metrics/:metric/latest' do
    get_single_metric(params, DateTime.now)
  end

  get '/metrics/:metric/today' do
    redirect("#{request.scheme}://#{request.host_with_port}/metrics/#{params[:metric]}/since-midnight")
  end

  get '/metrics/:metric/since-midnight' do
    params[:from] = DateTime.now.beginning_of_day.to_s
    params[:to] = DateTime.now.to_s
    get_metric_range(params)
  end

  get '/metrics/:metric/since-beginning-of-month' do
    params[:from] = DateTime.now.beginning_of_month.to_s
    params[:to] = DateTime.now.to_s
    get_metric_range(params)
  end

  get '/metrics/:metric/since-beginning-of-week' do
    params[:from] = DateTime.now.beginning_of_week.to_s
    params[:to] = DateTime.now.to_s
    get_metric_range(params)
  end

  get '/metrics/:metric/since-beginning-of-year' do
    params[:from] = DateTime.now.beginning_of_year.to_s
    params[:to] = DateTime.now.to_s
    get_metric_range(params)
  end

  get '/metrics/:metric/:time' do
    date_redirect(params)

    time = params[:time].to_datetime rescue
      error_400("'#{params[:time]}' is not a valid ISO8601 date/time.")

    get_single_metric(params, time)
  end

  get '/metrics/:metric/:from/:to' do
    date_redirect(params)
    get_metric_range(params)
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
