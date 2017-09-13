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

    class MetricMetadata < Grape::Entity

      expose :name
      expose :type
      expose :title
      expose :description
      expose :datatype

    end

  end
end