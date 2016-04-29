require 'mongoid'

class MetricMetadata
  include Mongoid::Document

  field :name,  type: String
  field :type,  type: String
  field :title, type: Hash, default: {}
  field :description, type: Hash, default: {}

  validates_inclusion_of :type, in: ['chart', 'tasklist', 'target', 'pie'], allow_nil: true

  index({ name: 1 }, { background: true })
end
