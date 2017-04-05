$:.unshift File.dirname(__FILE__)

require 'mongoid'
require 'grape'
Mongoid.load!(File.expand_path("../mongoid.yml", File.dirname(__FILE__)), ENV['RACK_ENV'])
Metric.create_indexes

module Bothan
  class Api < Grape::API

    Api.post '/metrics/:metric' do
      protected!

      body = JSON.parse request.body.read

      update_metric(params[:metric], body["time"], body["value"])
    end

    Api.post '/metrics/:metric/increment/?:amount?' do
      protected!

      last_metric = Metric.where(name: params[:metric].parameterize).last
      last_amount = last_metric.try(:[], 'value') || 0

      # Return 400 if the metric type is anything other than a single metric
      return 400 if last_amount.class == BSON::Document

      increment = (params[:amount] || 1).to_i
      value = last_amount + increment

      update_metric(params[:metric], DateTime.now, value)
    end

    Api.post '/metrics/:metric/metadata' do
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

  end
end
