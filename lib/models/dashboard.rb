require 'mongoid'

class Metric
  include Mongoid::Document

  field :name,  type: String
  field :metrics
end
