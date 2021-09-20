module Markdown
  module Model::Catalog
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :path, :string
      attribute :parent_path, :string

      belongs_to :parent, foreign_key: :parent_path, primary_key: :path

      has_many :posts
    end


  end
end
