module Bothan
  module Helpers
    module Metrics

      # pseudo controller functions, ones returning objects, ergo ones grape-entity concerns itself with

      def metadata(metric_name)
        # return Mongo MetricMetadata
        MetricMetadata.where(name: metric_name).first
      end

      def metric(metric_name, time = DateTime.now)
        # return Mongo Metric
        Metric.where(name: metric_name.parameterize, :time.lte => time).order_by(:time.asc).last
      end

      def list_metrics()
        # returns hash of mongo derived data and code generated URL
        return {
            metrics: Metric.all.distinct(:name).sort.map do |name|
              {
                  name: name,
                  url: "#{request.base_url}/metrics/#{name}.json"
              }
            end
        }
      end

      def get_measurement(params, time = DateTime.now)
        # return Hash, sets some instance vars
        metric = metric(params[:metric], time)
        @metric = (metric.nil? ? {} : metric).to_json
        @date = time.to_s
        @earliest_date = metrics.first.time rescue nil
        metric = JSON.parse(@metric, {:symbolize_names => true}) # what is returned?
        metric
      end

      def get_timeseries(params)
        @from = params[:from]
        @to = params[:to]

        dates = DateWrangler.new @from, @to

        if dates.errors
          # TODO This should raise a proper validation error instead
          raise ArgumentError.new(dates.errors.join(', '))
        end

        metrics = Metric.where(:name => params[:metric].parameterize).asc(:time)

        metrics = metrics.where(:time.gte => dates.from) if dates.from
        metrics = metrics.where(:time.lte => dates.to) if dates.to

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
        data
      end

      def increment_metric(increment)
        last_metric = Metric.where(name: params[:metric].parameterize).last
        last_amount = last_metric.try(:[], 'value') || 0
        if last_amount.class == BSON::Document # TODO this is the exception that should return for incrementing-metrics.feature:50
          raise MetricEndpointError, "the metric type cannot be incremented"
        else
          value = last_amount + increment
          update_metric(params[:metric], DateTime.now, value)
        end
      end

      def update_metric(name, time, value)
        @metric = Metric.new({
          "name" => name.parameterize,
          "time" => time,
          "value" => value
        })

        metadata = MetricMetadata.find_or_create_by(name: name.parameterize)

        if metadata.title.blank?
          metadata.title[:en] = name
          metadata.save
        end

        if @metric.save
          Pusher.trigger(name.parameterize, 'updated', {})
          return 201
        else
          return 500
        end
      end

      # ACTUAL helper methods

      def render_visualisation (params,data)
        @alternatives = get_alternatives(data[:value])
        get_settings(params, data)
        erb :metric, layout: "layouts/#{@layout}".to_sym
      end


      def title_from_slug_or_params(params)
        title = ActionView::Base.full_sanitizer.sanitize(URI.unescape params['title']) if params['title']
        title.to_s.empty? ? title_from_slug(params['metric']) : title
      end

      def title_from_slug(slug)
        return nil if slug.nil?
        words = slug.split('-')
        words.map { |word|
          word[0].upcase + word[1..-1].downcase
        }.join(' ')
      end

      def fix_pie_colours list
        list.split(':').map { |c| "##{c}" }.to_s.gsub('"', "'")
      end

      def get_title(metadata, params)
        if params['title'].blank?
          title = metadata.try(:title)
          if title.nil? || title == {}
            { "en" => title_from_slug_or_params(params) }
          else
            title
          end
        else
          { "en" => params['title'] }
        end
      end

      def generate_url(metric, params)
        url = datetime_path(metric, '')
        build_url(url, params.to_query)
      end

      def build_url(url, params)
        params = params.empty? ? nil : params
        [url, params].compact.join('?')
      end

      def single?(metric, datetime)
        [Hash, Array, BSON::Document].include?(metric.class) || datetime == "single"
      end

      def datetime_path(metric, datetime)
        now = Time.now.iso8601
        if single?(metric.value, datetime)
          "#{request.scheme}://#{request.host_with_port}/metrics/#{metric.name}/#{now}"
        else
          days = 30
          before = (Time.now - (60 * 60 * 24 * days)).iso8601
          "#{request.scheme}://#{request.host_with_port}/metrics/#{metric.name}/#{before}/#{now}"
        end
      end

      def default_date_redirect params
        date_set_and_redirect(params)
        if params['default-dates'].present?
          url = generate_url(metrics.first, keep_params(params))
          redirect to url
        end
      end

      def date_set_and_redirect params
        metrics = Metric.where(:name => params[:metric].parameterize).asc(:time)
        @earliest_date = metrics.first.time
        @latest_date = metrics.last.time

        if params['oldest'].present? && params['newest'].present?
          params['type'] = 'chart' if  ['pie', 'number', 'target'].include?(params['type'])
          redirect to "#{request.scheme}://#{request.host_with_port}/metrics/#{params[:metric]}/#{DateTime.parse(params['oldest']).to_s}/#{DateTime.parse(params['newest']).to_s}?#{sanitise_params params}"
        end

        if params['oldest'].present?
          redirect to "#{request.scheme}://#{request.host_with_port}/metrics/#{params[:metric]}/#{DateTime.parse(params['oldest']).to_s}?#{sanitise_params params}"
        end
      end

      def get_alternatives(value)
        alt = ['chart', 'number']
        if value.class == Array
          alt = ['tasklist']
        elsif single?(value, "")
          v = ActiveSupport::HashWithIndifferentAccess.new(value)
          alt << 'target' if v['annual_target']
          alt << 'pie' if v['total']
          alt = ['map'] if v['features']
        end
        alt
      end

      def keep_params qs
        params_to_keep = [
          'layout',
          'type',
          'boxcolour',
          'textcolour',
          'barcolour',
          'autorefresh',
          'with_path',
          'font_size',
          'pie_colours',
          'date_format',
          'tiles'
        ]

        good_params = {}

        qs.each_pair do |k, v|
          good_params[k] = v if params_to_keep.include? k
        end

        good_params
      end

      def sanitise_params qs
        a = []
        keep_params(qs).each_pair do |k, v|
          a.push "#{k}=#{v}"
        end

        a.join '&'
      end

      def visualisation_type(type, data)
        if type.nil?
          guess_type(data)
        else
          type
        end
      end

      def guess_type(data)
        if data.nil?
          'chart'
        elsif data[:value].class == String
          'chart'
        elsif data[:value].class == Array && !data[:value].empty? && data[:value].first[:progress].present?
          'tasklist'
        elsif [Hash, BSON::Document].include?(data[:value].class) && !data[:value][:annual_target].nil?
          'target'
        elsif [Hash, BSON::Document].include?(data[:value].class) && Hash[*data[:value].first].class == Hash
          data[:value][:type].nil? ? 'pie' : 'map'
        else
          'chart'
        end
      end

      def get_settings(params, data)

        metadata = metadata(params['metric'])

        @layout = params.fetch('layout', 'rich')
        @type = params.fetch('type', visualisation_type(metadata.try(:type), data))
        @boxcolour = "##{params.fetch('boxcolour', 'ddd')}"
        @textcolour = "##{params.fetch('textcolour', '222')}"
        @autorefresh = params.fetch('autorefresh', nil)
        @title = get_title(metadata, params)
        @datatype = metadata.try(:datatype)
        @description = metadata.try(:description) || {}
        @plotly_modebar = params.fetch('plotly_modebar', 'false')
        @font_size = params.fetch('font_size', '9vh')
        @metric = params.fetch('metric', '')
        @pie_colours = fix_pie_colours(params.fetch('pie_colours', ''))
        @date_format = params.fetch('date_format', 'YYYY-MM-DD HH:mm')
        @tiles = params.fetch('tiles', 'OpenStreetMap.Mapnik')
      end

      # mongrel methods

      def range_alias(endpoint)
        if /\w+-(.*)/.match(endpoint)
          # catch hypenathed endpoints, convert them to the supported ranges in DateAndTime::Calculations
          endpoint = $1.gsub(/-/, '_') # discard since preface
          params[:from] = DateTime.now.send(endpoint.to_sym).to_s
          params[:to] = DateTime.now.to_s
        else
          case endpoint
            when 'latest'
              @latest = get_measurement(params)
            when 'all'
              params[:from] = '*'
              params[:to] = '*'
            when 'today' || 'midnight'
              # then
              params[:from] = DateTime.now.beginning_of_day.to_s
              params[:to] = DateTime.now.to_s
          end
        end
        if params[:from].present?
          get_timeseries(params)
        else
          @latest # return single metric
        end
      end

    end
  end
end
