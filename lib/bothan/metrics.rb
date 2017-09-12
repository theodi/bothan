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

      app.post '/metrics/:metric/metadata' do
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
        data = get_metric_range(params)
        value = data[:values].first || { value: '' }
        render_visualisation(params, value)
      end

      app.get '/metrics/:metric/latest' do
        metric = get_single_metric(params, DateTime.now)
        render_visualisation(params, metric)
      end

      app.get '/metrics/:metric/today' do
        redirect("#{request.scheme}://#{request.host_with_port}/metrics/#{params[:metric]}/since-midnight")
      end

      app.get '/metrics/:metric/since-midnight' do
        params[:from] = DateTime.now.beginning_of_day.to_s
        params[:to] = DateTime.now.to_s
        data = get_metric_range(params)
        value = data[:values].first || { value: '' }
        render_visualisation(params, value)
      end

      app.get '/metrics/:metric/since-beginning-of-month' do

        params[:from] = DateTime.now.beginning_of_month.to_s
        params[:to] = DateTime.now.to_s
        data = get_metric_range(params)
        value = data[:values].first || { value: '' }
        render_visualisation(params, value)
      end

      app.get '/metrics/:metric/since-beginning-of-week' do
        params[:from] = DateTime.now.beginning_of_week.to_s
        params[:to] = DateTime.now.to_s
        data = get_metric_range(params)
        value = data[:values].first || { value: '' }
        render_visualisation(params, value)
      end

      app.get '/metrics/:metric/since-beginning-of-year' do
        params[:from] = DateTime.now.beginning_of_year.to_s
        params[:to] = DateTime.now.to_s
        data = get_metric_range(params)
        value = data[:values].first || { value: '' }
        render_visualisation(params, value)
      end

      app.get '/metrics/:metric/:time' do
        date_set_and_redirect(params)
        default_date_redirect(params)

        respond_to do |wants|
          wants.html do
            time = params[:time].to_datetime rescue
                error_400("'#{params[:time]}' is not a valid ISO8601 date/time.") #TODO maybe redundant

            metric = get_single_metric(params, time)
            render_visualisation(params, metric)
          end
        end

      end

      app.get '/metrics/:metric/:from/:to' do
        date_set_and_redirect(params)
        default_date_redirect(params)

        respond_to do |wants|

          wants.html do
            data = get_metric_range(params)
            value = data[:values].first || { value: '' }
            render_visualisation(params, value)
          end

          wants.other { error_406 }
        end
      end

    end

  end
end
