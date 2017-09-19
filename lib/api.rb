$:.unshift File.dirname(__FILE__)


require 'pusher'
require 'grape'
require 'grape-entity'
require 'grape-swagger'
require 'models/metrics'
require 'models/metadata'
require 'models/dashboard'

require 'bothan/extensions/date_wrangler'

require 'bothan/helpers/metrics_helpers'
require 'bothan/helpers/auth_helpers'

require 'entities' # needed

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
  # # TODO - use this block if/when this Ruby bug is fixed https://bugs.ruby-lang.org/issues/13661
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

      desc 'list all available metrics'

      get do
        metrics = list_metrics
        present metrics, with: Bothan::Entities::MetricList
      end

      params do
        requires :metric, type: String, desc: 'The name identifier where your metrics are stored'
      end
      route_param :metric do
      # params do, followed by route_param used to namespace enables the documentation desc for :metric to persist in all subsequent blocks
      # however using this method means that the documentation from Bothan::Entities does not surface
      # namespace 'metrics/:metric' do # can also be '/:metrics', but never :metric

        desc 'show latest value for given metric'
        get do
          metric = metric(params[:metric])
          present metric, with: Bothan::Entities::Metric
        end

        desc 'create a single metric',
             detail: 'create an endpoint by posting form data',
             params: Bothan::Entities::Metric.documentation # this is preferred as it lists the parameters as form data
        params do
          requires :time, type: DateTime, desc: 'the timestamp associated with a stored value'
          requires :value, desc: 'the value to store alongside a timestamp'
        end
        post do
          endpoint_protected!
          update_metric(params[:metric], params[:time], params[:value])
          if @metric.save
            present @metric, with: Bothan::Entities::Metric
          end
        end

        desc 'delete an entire metric endpoint'
        delete do
          endpoint_protected!
          params do
            requires :metric, type: String, desc: 'The name identifier where your metrics are stored'
          end
          Metric.where(name: params[:metric]).destroy_all
        end

        desc 'time based queries, return a timestamped value or values for an alias of time'
        params do
          optional :timespan, type: TimeSpanQueries, desc: 'Either an alias for common timespans or a Time value. Supported aliases include: "all","latest", "today", "since-midnight","since-beginning-of-month","since-beginning-of-week", "since-beginning-of-year"'
        end
        get ':timespan' do
          if %w(all latest today since-midnight since-beginning-of-month since-beginning-of-week since-beginning-of-year).include?(params[:timespan].value)
            range_alias(params[:timespan].value)
          else
            metric = metric(params[:metric], params[:timespan].value.to_datetime)
            present metric, with: Bothan::Entities::Metric
          end
        end

        # desc 'time queries'
        # # TODO - use this block instead of above block of same desc if/when this Ruby bug is fixed https://bugs.ruby-lang.org/issues/13661
        # # TODO - currently the below logic, and associated Grape::Validations::Base class EndpointAliases do not work because of 'since-beginning-month'
        # params do
        #   requires :timespan, types: [DateTime, EndpointAliases], desc: 'duration to parse'
        #   # disappointingly the above does not surface well within Grape Swagger
        # end
        # get '/:timespan' do
        #   if params[:timespan].to_datetime.instance_of?(DateTime)
        #       metric = single_metric(params[:metric], params[:timespan].to_datetime)
        #       metric
        #   else
        #     range_alias(params[:timespan])
        #   end
        # end

        desc 'list a time-series range of measurements for a given metric'

        params do
          requires :from, type: String, desc: 'the commencement date/time for your time-series range'
          optional :to, type: String, desc: 'the conclusion date/time for your time-series range'
        end

        get ':from/:to' do
          metrics = get_timeseries(params)
          present metrics, with: Bothan::Entities::MetricCollection
        end

        namespace '/increment' do
          desc 'auto-increment a metric'

          post do
            endpoint_protected!
            increment_metric(1)
            status 201
            present @metric, with: Bothan::Entities::Metric
          end

          desc 'increment a metric by stipulated amount' # home/metrics/:metric/increment"
          params do
            requires :amount, type: {value: Integer}, desc: 'amount to increase by'
          end
          post '/:amount' do
            endpoint_protected!
            increment = (params[:amount] || 1).to_i
            increment_metric(increment)

            if @metric.save
              status 201
              present @metric, with: Bothan::Entities::Metric
            end

          end
        end

        namespace '/metadata' do
          desc 'update a metrics metadata',
              detail: 'update below parameters by posting form data',
              params: Bothan::Entities::MetricMetadata.documentation
          post do
            endpoint_protected!
            # format :json #TODO - when refactoring into classes make this explicit at top of class
            meta = MetricMetadata.find_or_create_by(name: params[:metric].parameterize)
            meta.type = params[:type].presence
            meta.datatype = params[:datatype].presence
            meta.title.merge!(params[:title] || {}) # TODO these are breaking when used with grape, because they are set as hash in mongo document, N2K if they are to be kept as such
            meta.description.merge!(params[:description] || {}) # TODO these are breaking when used with grape, because they are set as hash in mongo document, N2K if they are to be kept as such
            if meta.save
              status 201
              present meta, with: Bothan::Entities::MetricMetadata
            else
              status 400
            end
          end
        end

        # end # END /<metric> namespace
      end # end route param

    end # end metrics namespace

    add_swagger_documentation
  end
end
