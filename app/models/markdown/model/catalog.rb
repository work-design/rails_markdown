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
      attribute :home_path, :string

      belongs_to :organ, class_name: 'Org::Organ', optional: true

      belongs_to :git
      belongs_to :parent, ->(o) { where(git_id: o.git_id) }, class_name: self.name, foreign_key: :parent_path, primary_key: :path, optional: true
      belongs_to :home, ->(o) { where(git_id: o.git_id) }, class_name: 'Post', foreign_key: :home_path, primary_key: :path, optional: true

      has_many :posts, ->(o) { where(git_id: o.git_id) }, primary_key: :path, foreign_key: :catalog_path
      has_many :children, ->(o) { where(git_id: o.git_id, depth: o.depth + 1) }, class_name: self.name, primary_key: :path, foreign_key: :parent_path
      has_many :siblings, ->(o) { where(git_id: o.git_id, depth: o.depth) }, class_name: self.name, primary_key: :parent_path, foreign_key: :parent_path

      scope :ordered, -> { order(position: :asc) }
      scope :nav, -> { where(nav: true) }
      scope :roots, -> { where(depth: 1) }

      normalizes :path, with: -> path { path.presence }

      acts_as_list scope: [:git_id, :depth]

      before_validation :deal_path, if: -> { path && path_changed? }
      before_validation :sync_organ, if: -> { git_id_changed? }
    end

    def deal_path
      r = path.split('/')
      self.parent_path = r[0..-2].join('/')
      self.name = r[-1]
      self.depth = r.size
      self.home_path = [path, 'README.md'].compact_blank.join('/')
      self.changes
    end

    def sync_organ
      self.organ_id = git.organ_id
    end

    def root?
      depth == 0
    end

    def ancestors
      r = path.split('/').ancestors[0..-2]
      r.prepend '' unless self.root?
      self.class.where(git_id: git_id).in_order_of(:path, r)
    end

  end
end
