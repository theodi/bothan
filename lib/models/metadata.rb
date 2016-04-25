require 'mongoid'

class MetricMetadata
  include Mongoid::Document

  field :name,  type: String
  field :title, type: Hash, default: {}
  field :description, type: Hash, default: {}

  index({ name: 1 }, { background: true })
end
