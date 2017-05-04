module Bothan
  module Metrics

    def self.registered(app)

      # shared with Grape

      app.get '/metrics' do
        @metrics = {
          metrics: Metric.all.distinct(:name).sort.map do |name|
            {
              name: name,
              url: "#{request.base_url}/metrics/#{name}.json"
            }
          end
        }

        @title = 'Metrics API'
        @created = Metric.first.time rescue DateTime.parse("2015-01-01T00:00:00Z")
        @updated = Metric.last.time rescue DateTime.parse("2016-01-01T00:00:00Z")
        erb :metrics, layout: 'layouts/default'.to_sym

      end

      app.get '/metrics/:metric/metadata' do #TODO will require Grape serving refactor
        protected!
        # Instance Variables Set by Mongo Models Methods, utilised in Sinatra Views
        @metric = Metric.find_by(name: params[:metric].parameterize)
        @metadata = MetricMetadata.find_or_initialize_by(name: params[:metric].parameterize)
        @allowed_datatypes = MetricMetadata.validators.find { |v| v.attributes == [:datatype] }.send(:delimiter)

        @alternatives = get_alternatives(@metric.value)

        @title = {
          'en' => 'Metadata'
        }
        erb :metadata, layout: 'layouts/default'.to_sym

      end

      app.get '/metrics/:metric/?' do
        # intended functionality is for a redirect to a chart display last N days of data
        @metric = Metric.where(name: params[:metric].parameterize).order_by(:time.asc).last
        url = generate_url(@metric, keep_params(request.params))
        redirect to url
      end

      app.get '/metrics/:metric/:from/:to' do
        date_redirect(params)
        get_metric_range(params)
      end

      # aliases

      # app.get '/metrics/:metric/all' do
      #   params[:from] = '*'
      #   params[:to] = '*'
      #   get_metric_range(params)
      # end
      #
      # app.get '/metrics/:metric/latest' do
      #   get_single_metric(params)
      # end
      #
      # app.get '/metrics/:metric/today' do
      #   redirect("#{request.scheme}://#{request.host_with_port}/metrics/#{params[:metric]}/since-midnight")
      # end
      #
      # app.get '/metrics/:metric/since-midnight' do
      #   params[:from] = DateTime.now.beginning_of_day.to_s
      #   params[:to] = DateTime.now.to_s
      #   get_metric_range(params)
      # end
      #
      # app.get '/metrics/:metric/since-beginning-of-month' do
      #   params[:from] = DateTime.now.beginning_of_month.to_s
      #   params[:to] = DateTime.now.to_s
      #   get_metric_range(params)
      # end
      #
      # app.get '/metrics/:metric/since-beginning-of-week' do
      #   params[:from] = DateTime.now.beginning_of_week.to_s
      #   params[:to] = DateTime.now.to_s
      #   get_metric_range(params)
      # end
      #
      # app.get '/metrics/:metric/since-beginning-of-year' do
      #   params[:from] = DateTime.now.beginning_of_year.to_s
      #   params[:to] = DateTime.now.to_s
      #   get_metric_range(params)
      # end
      #
      # app.get '/metrics/:metric/:time' do
      #   date_redirect(params)
      #
      #   time = params[:time].to_datetime rescue
      #     error_400("'#{params[:time]}' is not a valid ISO8601 date/time.")
      #
      #   get_single_metric(params, time)
      # end

    end

  end
end
