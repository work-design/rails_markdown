module Markdown
  module Model::Catalog
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :path, :string
      attribute :parent_path, :string
      attribute :position, :integer
      attribute :nav, :boolean, default: false, comment: '是否导航菜单'
      attribute :depth, :integer

      belongs_to :organ, class_name: 'Org::Organ', optional: true

      belongs_to :parent, class_name: self.name, foreign_key: :parent_path, primary_key: :path, optional: true
      belongs_to :git

      has_many :posts, ->(o) { where(git_id: o.git_id) }, foreign_key: :catalog_path, primary_key: :path
      has_many :children, class_name: self.name, foreign_key: :parent_path, primary_key: :path

      default_scope -> { order(position: :asc) }
      scope :nav, -> { where(nav: true) }
      scope :roots, -> { where(depth: 2) }

      acts_as_list scope: [:git_id, :depth]

      before_validation :sync_parent_path, if: -> { path.present? && path_changed? }
      before_validation :sync_organ, if: -> { git_id_changed? }
    end

    def sync_parent_path
      r = path.split('/')
      self.parent_path = r[0..-2].join('/')
      self.name = r[-1]
      self.depth = r.size
    end

    def sync_organ
      self.organ_id = git.organ_id
    end

  end
end
