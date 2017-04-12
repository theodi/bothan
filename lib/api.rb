$:.unshift File.dirname(__FILE__)

require 'mongoid'
require 'pusher'
require 'bothan/extensions/date_wrangler'
require 'grape'
require 'models/metrics'
require 'models/metadata'
require 'models/dashboard'
require 'bothan/helpers/metrics_helpers'

Mongoid.load!(File.expand_path("../mongoid.yml", File.dirname(__FILE__)), ENV['RACK_ENV'])
Metric.create_indexes

module Bothan
  class Api < Grape::API
    content_type :json, 'application/json; charset=UTF-8'
    helpers do
      def update_metric(name, time, value)
        @metric = Metric.new({
            "name" => name.parameterize,
            "time" => time,
            "value" => value
        })

        metadata = MetricMetadata.find_or_create_by(name: name.parameterize)

        if metadata.title.blank?
          # binding.pry
          metadata.title[:en] = name
          metadata.save
        end

        if @metric.save
          Pusher.trigger(name.parameterize, 'updated', {})
          return 201 # status instead of return???
        else
          return 500
        end
      end
    end

    #TODO - 5 methods from the Sinatra helper added to here - decide what to do RE this functionality
    def get_single_metric(params, time)
      time ||= DateTime.now
      metrics = Metric.where(name: params[:metric].parameterize, :time.lte => time).order_by(:time.asc)
      metric = metrics.last

      if params['default-dates'].present?
        url = generate_url(metric, keep_params(params))
        redirect to url
      end

      @metric = (metric.nil? ? {} : metric).to_json

      @date = time.to_s
      @earliest_date = metrics.first.time rescue nil

      metric = JSON.parse(@metric, {:symbolize_names => true})
      @alternatives = get_alternatives(metric[:value])

      get_settings(params, metric)
      erb :metric, layout: "layouts/#{@layout}".to_sym

    end

    def get_metric_range(params)
      @from = params[:from]
      @to = params[:to]

      dates = DateWrangler.new @from, @to

      error_400 dates.errors.join ' ' if dates.errors

      metrics = Metric.where(:name => params[:metric].parameterize).asc(:time)

      if params['default-dates'].present?
        url = generate_url(metrics.first, keep_params(params))
        redirect to url
      end

      @earliest_date = metrics.first.time
      @latest_date = metrics.last.time

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


      value = data[:values].first || { value: '' }
      @alternatives = get_alternatives(value[:value])

      binding.pry

      get_settings(params, value)

      erb :metric, layout: "layouts/#{@layout}".to_sym

    end

    def date_redirect params
      if params['oldest'].present? && params['newest'].present?
        params['type'] = 'chart' if  ['pie', 'number', 'target'].include?(params['type'])
        redirect to "#{request.scheme}://#{request.host_with_port}/metrics/#{params[:metric]}/#{DateTime.parse(params['oldest']).to_s}/#{DateTime.parse(params['newest']).to_s}?#{sanitise_params params}"
      end

      if params['oldest'].present?
        redirect to "#{request.scheme}://#{request.host_with_port}/metrics/#{params[:metric]}/#{DateTime.parse(params['oldest']).to_s}?#{sanitise_params params}"
      end
    end

    def sanitise_params qs
      a = []
      keep_params(qs).each_pair do |k, v|
        a.push "#{k}=#{v}"
      end

      a.join '&'
    end

    get '/' do
      redirect "#{request.scheme}://#{request.host_with_port}/metrics"
    end

    namespace :metrics do

      desc 'list all available metrics' # conflicts with sinatra
      # /metrics[.json]
      # get '.json' do # this feels like a very UGLY workaround to conflict problem - confirmed when it doesnt solve problems elsewhere
      get do # this feels like a very UGLY workaround to conflict problem - confirmed when it doesnt solve problems elsewhere
        @metrics = {
          metrics: Metric.all.distinct(:name).sort.map do |name|
            {
              name: name,
              url: "#{request.base_url}/metrics/#{name}.json"
            }
          end
        }
        @metrics
      end

      desc 'create a single metric'

      post '/:metric' do
        params do
          # requires :metric, type: String, desc: 'new metric'
          requires :time, type: String, desc: 'metric timestamp'
          requires :value, types: [Integer, Hash], desc: 'metric value or values'
        end

        # format :json #TODO - when refactoring into classes make this explicit at top of class to reduce Headers passed via curl
        update_metric(params[:metric], params[:time], params[:value])
      end
    end

    namespace 'metrics/:metric' do # required because nested namespace or something

      desc 'show latest value for given metric' # /metrics/{metric_name}[.json]
      params do
        requires :metric, type: String, desc: 'metric names'
      end
      get do
        @metric = Metric.where(name: params[:metric].parameterize).order_by(:time.asc).last
        @metric
      end

      desc 'show value for given metric at a given time (defaults to current time)' # /metrics/{metric_name}/{time}
      params do
        requires :time, type: DateTime
      end
      get '/:time' do
        binding.pry
        # format params[:time]
        # date_redirect(params)
        # get_single_metric(params, time)
      end

      desc 'list values for given metric between given range' # /metrics/{metric_name}/{from}/{to}

      params do
        requires :from, types: [DateTime, String]
        requires :to, types: [DateTime, String]
      end
      get '/:from/:to' do
        {searchstring: "will return vals from "+params[:start_date].to_s+" until "+params[:end_date].to_s}
        #   date_redirect(params)
        #   get_metric_range(params)
      end

      desc 'increment a metric' # home/metrics/:metric/increment"
      params do
        requires :amount, type: Integer, desc: 'amount to increase by'
        # requires :amount, coerce: Integer
      end
      post '/:increment' do
        last_metric = Metric.where(name: params[:metric].parameterize).last
        last_amount = last_metric.try(:[], 'value') || 0
        return 400 if last_amount.class == BSON::Document
        increment = (params[:amount] || 1).to_i
        value = last_amount + increment
        update_metric(params[:metric], DateTime.now, value)
      end

    end # end metrics/:metric namespace

    namespace 'metrics/:metric/metadata' do
      get do
        @metric = Metric.find_by(name: params[:metric].parameterize)
        @metadata = MetricMetadata.find_or_initialize_by(name: params[:metric].parameterize)
        # @allowed_datatypes = MetricMetadata.validators.find { |v| v.attributes == [:datatype] }.send(:delimiter) # TODO methods in metrics_helpers.rb, N2K if this is to be retained
        @metadata
      end

      params do
        requires :metric, type: String, desc: 'metric to be meta-dated and fed to mongo'
        requires :type, type: String, desc: 'default metric visualisation', values: ['chart', 'tasklist', 'target', 'pie', 'number']
        requires :datatype, type: String, desc: 'type of metrics, e.g. currency or percentage', values: ['percentage', 'currency']
        optional :title, type: Hash, desc: 'metric title'
        optional :description, type: Hash, desc: 'metric description'
        # optional :title, type: String, desc: 'metric title'
        # optional :description, type: String, desc: 'metric description'
      end
      post do
        # format :json #TODO - when refactoring into classes make this explicit at top of class
        @meta = MetricMetadata.find_or_create_by(name: params[:metric].parameterize)
        @meta.type = params[:type].presence
        @meta.datatype = params[:datatype].presence
        @meta.title.merge!(params[:title] || {}) # TODO these are breaking when used with grape, because they are set as hash in mongo document, N2K if they are to be kept as such
        @meta.description.merge!(params[:description] || {}) # TODO these are breaking when used with grape, because they are set as hash in mongo document, N2K if they are to be kept as such
        if @meta.save # TODO - this endpoint exits here
          status 201
        else
          status 400
          # maybe superfluous given Grape automatically returns this on POST success
        end
      end
    end

  end
end
