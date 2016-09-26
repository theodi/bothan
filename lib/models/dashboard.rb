require 'mongoid'

class Dashboard
  include Mongoid::Document

  validates_uniqueness_of :slug

  field :name,     type: String
  field :slug,     type: String, default: -> { name.parameterize }
  field :rows,     type: Integer
  field :columns,  type: Integer
  field :metrics
end
