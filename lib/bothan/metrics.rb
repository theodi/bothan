module Bothan
  module Metrics

    def self.registered(app)

      app.get '/metrics' do
        # byebug
        @metrics = list_metrics
        @title = 'Metrics API'
        @created = Metric.first.time rescue DateTime.parse("2015-01-01T00:00:00Z")
        @updated = Metric.last.time rescue DateTime.parse("2016-01-01T00:00:00Z")
        erb :metrics, layout: 'layouts/default'.to_sym

      end

      app.get '/metrics/:metric/metadata' do
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

      app.get '/metrics/:metric/?' do
        # byebug
        @metric = Metric.where(name: params[:metric].parameterize).order_by(:time.asc).last
        respond_to do |wants|
          # wants.json { @metric.to_json }

          wants.html do
            url = generate_url(@metric, keep_params(request.params))
            redirect to url
          end

          wants.other { error_406 }
        end
      end

      app.get '/metrics/:metric/all' do
        params[:from] = '*'
        params[:to] = '*'
        get_metric_range(params)
      end

      app.get '/metrics/:metric/latest' do
        get_single_metric(params, DateTime.now)
      end

      app.get '/metrics/:metric/today' do
        redirect("#{request.scheme}://#{request.host_with_port}/metrics/#{params[:metric]}/since-midnight")
      end

      app.get '/metrics/:metric/since-midnight' do
        params[:from] = DateTime.now.beginning_of_day.to_s
        params[:to] = DateTime.now.to_s
        get_metric_range(params)
      end

      app.get '/metrics/:metric/since-beginning-of-month' do
        params[:from] = DateTime.now.beginning_of_month.to_s
        params[:to] = DateTime.now.to_s
        get_metric_range(params)
      end

      app.get '/metrics/:metric/since-beginning-of-week' do
        params[:from] = DateTime.now.beginning_of_week.to_s
        params[:to] = DateTime.now.to_s
        get_metric_range(params)
      end

      app.get '/metrics/:metric/since-beginning-of-year' do
        params[:from] = DateTime.now.beginning_of_year.to_s
        params[:to] = DateTime.now.to_s
        get_metric_range(params)
      end

      app.get '/metrics/:metric/:time' do
        # byebug
        date_set_and_redirect(params)

        if params['default-dates'].present? #TODO refactor into a method that both functions can call
          url = generate_url(metrics.first, keep_params(params))
          redirect to url
        end

        respond_to do |wants|
          wants.html do
            time = params[:time].to_datetime rescue
                error_400("'#{params[:time]}' is not a valid ISO8601 date/time.") #TODO maybe redundant

            metric = get_single_metric(params, time)
            @alternatives = get_alternatives(metric[:value])

            get_settings(params, metric)

            erb :metric, layout: "layouts/#{@layout}".to_sym
          end
        end

      end

      app.get '/metrics/:metric/:from/:to' do
        date_set_and_redirect(params)

        if params['default-dates'].present?
          url = generate_url(metrics.first, keep_params(params))
          redirect to url
        end

        respond_to do |wants|

          wants.html do
            data = get_metric_range(params)
            value = data[:values].first || { value: '' }
            @alternatives = get_alternatives(value[:value])

            get_settings(params, value)

            erb :metric, layout: "layouts/#{@layout}".to_sym
          end

          wants.other { error_406 }
        end
      end

    end

  end
end
