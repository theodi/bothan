$:.unshift File.dirname(__FILE__)

require 'mongoid'
require 'pusher'
require 'grape'
require 'models/metrics'
require 'models/metadata'
require 'models/dashboard'

require 'bothan/extensions/date_wrangler'

require 'bothan/helpers/metrics_helpers'

Mongoid.load!(File.expand_path("../mongoid.yml", File.dirname(__FILE__)), ENV['RACK_ENV'])
Metric.create_indexes

module Bothan
  class Api < Grape::API
    content_type :json, 'application/json; charset=UTF-8'

    helpers Bothan::Helpers::Metrics

    namespace :metrics do

      desc 'list all available metrics' # conflicts with sinatra

      get do

       list_metrics

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

    namespace 'metrics/:metric' do

      desc 'show latest value for given metric' # /metrics/{metric_name}[.json]
      params do
        requires :metric, type: String, desc: 'metric names'
      end
      get do
        @metric = Metric.where(name: params[:metric].parameterize).order_by(:time.asc).last
        @metric
      end

      desc 'time and date range endpoints'
      params do
        # requires :endpoint, types: [DateTime, String]
        requires :endpoint, types: String

      end
      get '/:endpoint' do
        @supported_aliases = ['all','latest', 'today', 'since-midnight','since-beginning-of-month','since-beginning-of-week', 'since-beginning-of-year']
        # case params[:endpoint]
        # when DateTime
        #   then
        #   get_single_metric(params, params[:endpoint])
        # when String
        # end
        if @supported_aliases.include?(params[:endpoint])
          range_alias(params[:endpoint])
        elsif params[:endpoint].to_datetime.instance_of? DateTime
          get_single_metric(params, params[:endpoint].to_datetime)
        else
          {error: 'endpoint not supported'} # TODO recuperate the Time rescue from original endpoint, no longer possible to use Grape validation for this because bug above
        end
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

      desc 'delete an entire metric endpoint'
      delete do
        params do
          requires :metric, type: String, desc: 'metric names'
        end
        Metric.where(name: params[:metric]).destroy_all
      end

    end

    namespace 'metrics/:metric/metadata' do
      
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
