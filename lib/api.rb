$:.unshift File.dirname(__FILE__)


require 'pusher'
require 'grape'
require 'models/metrics'
require 'models/metadata'
require 'models/dashboard'

require 'bothan/extensions/date_wrangler'

require 'bothan/helpers/metrics_helpers'
require 'bothan/helpers/auth_helpers'

module Bothan
  class MetricEndpointError < StandardError

  end

  class TimeSpanQueries
    attr_reader :value
    def initialize(aliased)
      @value = aliased
    end

    def self.parse(value)
      if !['all','latest', 'today', 'since-midnight','since-beginning-of-month','since-beginning-of-week', 'since-beginning-of-year'].include?(value) && !value.to_datetime.instance_of?(DateTime)
        fail 'Invalid alias'
      end
      new(value)
    end
  end

  # class EndpointAliases < Grape::Validations::Base
  # TODO - use this block if/when this Ruby bug is fixed https://bugs.ruby-lang.org/issues/13661
  #   def validate_param!(attr_name, params)
  #     unless ['all','latest', 'today', 'since-midnight','since-beginning-of-month','since-beginning-of-week', 'since-beginning-of-year'].include?(params[attr_name])
  #       fail Grape::Exceptions::Validation, params: [@scope.full_name(attr_name)], message: 'must be a recognised endpoint alias'
  #     end
  #   end
  # end

  class Api < Grape::API
    content_type :json, 'application/json; charset=UTF-8'

    helpers Bothan::Helpers::Metrics
    helpers Bothan::Helpers::Auth


    rescue_from MetricEndpointError do |e|
      error!({status: e}, 400)
    end

    rescue_from ArgumentError do |e|
      # byebug
      if e.message == "invalid date"
        error!({status: "passed parameters are not a valid ISO8601 date/time."}, 400)
      else
        error!({status: e.message}, 400)
      end
    end

    rescue_from Grape::Exceptions::ValidationErrors do |e|
      # byebug
      if e.message == "timespan is invalid"
        error!({status: "time is not a valid ISO8601 date/time."}, 400)
      else
        error!({status: e.message}, 400)
      end
    end

    rescue_from ISO8601::Errors::UnknownPattern do |e|
      error!({status: "passed parameters are not a valid ISO8601 date/time."}, 400)
    end

    namespace :metrics do

      desc 'list all available metrics' # conflicts with sinatra

      get do

       list_metrics

      end


      desc 'create a single metric'

      post '/:metric' do

        endpoint_protected!
        params do
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
        metric = Metric.where(name: params[:metric].parameterize).order_by(:time.asc).last
        metric
      end

      desc 'delete an entire metric endpoint'
      delete do
        endpoint_protected!
        params do
          requires :metric, type: String, desc: 'metric names'
        end
        Metric.where(name: params[:metric]).destroy_all
      end

      desc 'time queries'
      params do
        optional :timespan, type: TimeSpanQueries
      end
      get ':timespan' do
        # byebug
        if %w(all latest today since-midnight since-beginning-of-month since-beginning-of-week since-beginning-of-year).include?(params[:timespan].value)
          range_alias(params[:timespan].value)
        else
          metric = single_metric(params[:metric], params[:timespan].value.to_datetime)
          metric
        end
      end

      # desc 'time queries'
      # TODO - use this block instead of above block of same desc if/when this Ruby bug is fixed https://bugs.ruby-lang.org/issues/13661
      # TODO - currently the below logic, and associated Grape::Validations::Base class EndpointAliases do not work because of 'since-beginning-month'
      # params do
      #   requires :timespan, types: [DateTime, EndpointAliases]
      # end
      # get '/:timespan' do
      #   if params[:timespan].to_datetime.instance_of?(DateTime)
      #       metric = single_metric(params[:metric], params[:timespan].to_datetime)
      #       metric
      #   else
      #     range_alias(params[:timespan])
      #   end
      # end

    end

    namespace 'metrics/:metric/increment' do
      desc 'increment a metric' # home/metrics/:metric/increment"

      post do
        endpoint_protected!
        increment_metric(1)
      end

      post '/:amount' do

        endpoint_protected!
        params do
          requires :amount, type: {value: Integer}, desc: 'amount to increase by'
        end
        increment = (params[:amount] || 1).to_i
        increment_metric(increment)

      end
    end


    desc 'ranges'

    params do
      requires :from
      optional :to
    end

    get 'metrics/:metric/:from/:to' do
      get_metric_range(params)
    end

    namespace 'metrics/:metric/metadata' do

      get do
        metadata = MetricMetadata.find_or_initialize_by(name: params[:metric].parameterize)
        metadata
      end

      params do
          optional :metric, type: String, desc: 'metric to be meta-dated and fed to mongo'
          optional :type, type: String, desc: 'default metric visualisation', values: ['chart', 'tasklist', 'target', 'pie', 'number']
          optional :datatype, type: String, desc: 'type of metrics, e.g. currency or percentage', values: ['percentage', 'currency']
          optional :title, type: Hash, desc: 'metric title'
          optional :description, type: Hash, desc: 'metric description'
      end
      post do
        endpoint_protected!
        # format :json #TODO - when refactoring into classes make this explicit at top of class
        meta = MetricMetadata.find_or_create_by(name: params[:metric].parameterize)
        meta.type = params[:type].presence
        meta.datatype = params[:datatype].presence
        meta.title.merge!(params[:title] || {}) # TODO these are breaking when used with grape, because they are set as hash in mongo document, N2K if they are to be kept as such
        meta.description.merge!(params[:description] || {}) # TODO these are breaking when used with grape, because they are set as hash in mongo document, N2K if they are to be kept as such
        meta.save

      end
    end

  end
end
