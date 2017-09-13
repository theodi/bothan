require 'grape'
require 'grape-entity'

module Bothan
  module Entities

    class Metrics < Grape::Entity

      expose :metrics

    end

    class Metric < Grape::Entity

      expose :name
      expose :time
      expose :value

    end


    class MetricRange < Metric

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