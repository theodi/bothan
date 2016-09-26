require 'mongoid'

class Dashboard
  include Mongoid::Document

  validates_format_of :slug, with: /\A[a-z0-9\-]*\Z/
  validates_uniqueness_of :slug

  field :name,     type: String
  field :slug,     type: String
  field :rows,     type: Integer
  field :columns,  type: Integer
  field :metrics
end
