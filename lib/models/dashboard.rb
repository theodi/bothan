require 'mongoid'

class Dashboard
  include Mongoid::Document

  field :slug,  type: String
  field :name,  type: String
  field :rows,  type: String
  field :columns,  type: String
  field :metrics
end
