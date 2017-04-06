$:.unshift File.dirname(__FILE__)

require 'mongoid'
require 'pusher'
require 'grape'
require 'models/metrics'
require 'models/metadata'
require 'models/dashboard'

Mongoid.load!(File.expand_path("../mongoid.yml", File.dirname(__FILE__)), ENV['RACK_ENV'])
Metric.create_indexes

module Bothan
  class Api < Grape::API
    format :json
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
        @metrics.to_json
      end

      desc 'create a single metric'
      route_param :metric do
        params do
          requires :metric, type: String, desc: 'new metric'
          requires :time, type: String, desc: 'metric timestamp'
          requires :value, type: Integer, desc: 'metric value'
        end
        post do
          update_metric(params[:metric], params[:time], params[:value])
        end
      end # end route_param
    end

    namespace 'metrics/:metric' do # required because nested namespace or something

      desc 'create a single metric'

      params do
        requires :metric, type: String, desc: 'new metric'
        requires :time, type: String, desc: 'metric timestamp'
        requires :value, type: Integer, desc: 'metric value'
      end
      post do
        # above will retrive metric as a parameter within the params hash along with params passed by body
        update_metric(params[:metric], params[:time], params[:value])
      end

      desc 'show latest value for given metric' # /metrics/{metric_name}[.json]
      params do
        requires :metric, type: String, desc: 'metric names'
      end
      get do

        @metric = Metric.where(name: params[:metric].parameterize).order_by(:time.asc).last
        @metric.to_json
      end

      desc 'show value for given metric at a given time (defaults to current time)' # /metrics/{metric_name}/{time}

    end

    namespace 'metrics/:metric/:start_date/:end_date' do
      desc 'list values for given metric between given range' # /metrics/{metric_name}/{from}/{to}

      params do
        requires :start_date, type: DateTime
        requires :end_date, type: DateTime
      end
      get do
        binding.pry
        {searchstring: "will return vals from "+params[:start_date]+" until "+params[:end_date]}
      end

    end
    
    # OLD API CODE

    # Api.post '/metrics/:metric' do
    #   protected!
    #
    #   body = JSON.parse request.body.read
    #
    #   update_metric(params[:metric], body["time"], body["value"])
    # end

    # Api.post '/metrics/:metric/increment/?:amount?' do
    #   protected!
    #
    #   last_metric = Metric.where(name: params[:metric].parameterize).last
    #   last_amount = last_metric.try(:[], 'value') || 0
    #
    #   # Return 400 if the metric type is anything other than a single metric
    #   return 400 if last_amount.class == BSON::Document
    #
    #   increment = (params[:amount] || 1).to_i
    #   value = last_amount + increment
    #
    #   update_metric(params[:metric], DateTime.now, value)
    # end
    #
    # Api.post '/metrics/:metric/metadata' do
    #   protected!
    #   begin
    #     data = JSON.parse request.body.read
    #     @meta = MetricMetadata.find_or_create_by(name: params[:metric].parameterize)
    #     @meta.type = data["type"].presence
    #     @meta.datatype = data["datatype"].presence
    #     @meta.title.merge!(data["title"] || {})
    #     @meta.description.merge!(data["description"] || {})
    #     if @meta.save
    #       return 201
    #     else
    #       return 400
    #     end
    #   rescue
    #     return 500
    #   end
    # end

  end
end
