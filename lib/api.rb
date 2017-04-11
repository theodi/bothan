$:.unshift File.dirname(__FILE__)

require 'mongoid'
require 'pusher'
require 'bothan/extensions/date_wrangler'
require 'grape'
require 'models/metrics'
require 'models/metadata'
require 'models/dashboard'

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
          requires :metric, type: String, desc: 'new metric'
          requires :time, type: String, desc: 'metric timestamp'
          requires :value, type: Integer, desc: 'metric value'
        end
        # format :json #TODO - when refactoring into classes make this explicit at top of class
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

      desc 'increment a metric' # home/metrics/:metric/increment/375"
      # TODO this is a nested resource that has same number of route params as a daterange query
      # namespace :increment do
      #   params do
      #     requires :amount, coerce: Integer
      #   end
      #   get do
      #     binding.pry
      #   end
      #   post :amount do
      #     #TODO - change logic below, still in original API form
      #     last_metric = Metric.where(name: params[:metric].parameterize).last
      #     last_amount = last_metric.try(:[], 'value') || 0
      #
      #     # Return 400 if the metric type is anything other than a single metric
      #     return 400 if last_amount.class == BSON::Document
      #
      #     increment = (params[:amount] || 1).to_i
      #     value = last_amount + increment
      #
      #     update_metric(params[:metric], DateTime.now, value)
      #   end
      # end
      ## TODO the above two conflict with one another - no straightforward resolution
      desc 'list values for given metric between given range' # /metrics/{metric_name}/{from}/{to}
      # namespace :start_date, type: DateTime do
      #   params do
      #     requires :end_date, type: DateTime
      #   end
      #   get do
      #     # binding.pry
      #     {searchstring: "will return vals from "+params[:start_date].to_s+" until "+params[:end_date].to_s}
      #   end
      # end

    end # end metrics/:metric namespace

    namespace 'metrics/:metric/:start_date/:end_date' do
      #TODO - utilise date wrangler for this
    # this is outside of the above namespace ONLY because of Sinatra conflicts BUT it hogs all route params after :metric
      # this is because https://github.com/ruby-grape/grape#parameters -
      desc 'list values for given metric between given range' # /metrics/{metric_name}/{from}/{to}
      params do
        # TODO some way of accommodating wildcard char for both params
        requires :start_date, type: DateTime
        requires :end_date, type: DateTime
      end
      get do
        #TODO - correct logic
        {searchstring: "will return vals from "+params[:start_date].to_s+" until "+params[:end_date].to_s}
      end
    end

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
