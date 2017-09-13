require 'grape'
require 'grape-entity'

module Bothan
  module Entities

    class Metric < Grape::Entity

      expose :name

    end

    class Measurement < Grape::Entity


      expose :time
      expose :value

    end


    class TimeSeries < Grape::Entity

      unexpose :name
      expose :count
      # expose :values, using: Bothan::Entities::Metric, as: :values
      # doesn't work because :name persists in the response, no seeming way to easily scrub it
      expose :values
      # this feels like bad code - inherting and then reexposing but nothing native in grape to support

    end


    class MetricMetadata < Grape::Entity

      expose :name
      expose :type
      expose :title
      expose :description
      expose :datatype

    end

  end
end