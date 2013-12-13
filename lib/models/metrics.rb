require 'mongoid'

class Metric
  include Mongoid::Document
  
  field :name,  type: String
  field :time,  type: DateTime
  field :value
  
end