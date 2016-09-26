require 'mongoid'

class Dashboard
  include Mongoid::Document

  before_create :create_slug

  field :slug,  type: String
  field :name,  type: String
  field :rows,  type: String
  field :columns,  type: String
  field :metrics

  def create_slug
    self.slug = self.name.parameterize
  end

  index({ slug: 1 } , { unique: true })
end
