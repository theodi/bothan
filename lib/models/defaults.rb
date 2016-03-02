require 'mongoid'

class MetricDefault
  include Mongoid::Document

  field :name,  type: String
  field :type,  type: String

  validates_inclusion_of :type, in: ['chart', 'tasklist', 'target', 'pie']

  index({ name: 1 }, { background: true })
end
