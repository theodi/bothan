require 'grape'
require 'grape-entity'

module Bothan
  module Entities

    class MetricList < Grape::Entity
      expose :metrics
      # this passes the tests but there is no relationship between this class and the Metric class below
    end

    class Metric < Grape::Entity

      expose :time
      expose :value

    end

    class MetricCollection < Grape::Entity

      expose :count
      expose :values, using: Bothan::Entities::Metric

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