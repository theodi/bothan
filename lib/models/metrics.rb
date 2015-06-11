require 'mongoid'

class Metric
  include Mongoid::Document
  
  field :name,  type: String
  field :time,  type: DateTime
  field :value
  
  index({ name: 1 }, { background: true })
  index({ time: -1 }, { background: true })
  index({ name: 1, time: -1 }, { background: true, unique: true })

end