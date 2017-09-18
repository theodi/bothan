require 'grape'
require 'grape-entity'

module Bothan
  module Entities

    class Metrics < Grape::Entity
      expose :metrics
      # this passes the tests but there is no relationship between this class and the Metric class below
    end

    class Metric < Grape::Entity

      expose :url
      expose :name
      expose :time
      expose :value


      # expose :metrics do
      #   expose :name
      #   expose :url
      # end
      # expose :name
      # expose :url unless :name
      #
      # expose :time if :name
      # expose :value if :name
      # works for metric/QUERY but not /metrics

    end

    class MetricMetadata < Grape::Entity

      expose :name
      expose :type
      expose :title
      expose :description
      expose :datatype

    end


    # class Measurement < Grape::Entity
    #
    #
    #   expose :time
    #   expose :value
    #
    # end
    #
    #
    # class TimeSeries < Grape::Entity
    #
    #   unexpose :name
    #   expose :count
    #   # expose :values, using: Bothan::Entities::Metric, as: :values
    #   # doesn't work because :name persists in the response, no seeming way to easily scrub it
    #   expose :values
    #   # this feels like bad code - inherting and then reexposing but nothing native in grape to support
    #
    # end


  end
end