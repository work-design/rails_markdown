module Markdown
  module Model::Catalog
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :path, :string
      attribute :parent_path, :string

      belongs_to :parent, foreign_key: :parent_path, primary_key: :path, optional: true

      has_many :posts, foreign_key: :catalog_path, primary_key: :path

      before_validation :sync_parent_path, if: -> { path_changed? }
    end

    def sync_parent_path
      r = path.split('/')
      self.parent_path = r[0..-2].join('/')
      self.name = r[-1]
    end

  end
end