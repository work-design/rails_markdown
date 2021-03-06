module Markdown
  module Model::Post
    extend ActiveSupport::Concern

    included do
      attribute :title, :string
      attribute :markdown, :string
      attribute :html, :string
      attribute :layout, :string
      attribute :path, :string
      attribute :catalog_path, :string, default: ''
      attribute :oid, :string
      attribute :published, :boolean, default: true
      attribute :ppt, :boolean, default: false
      attribute :nav, :boolean, default: false, comment: '是否导航菜单'

      belongs_to :git
      belongs_to :organ, class_name: 'Org::Organ', optional: true
      belongs_to :catalog, ->(o){ where(git_id: o.git_id) }, foreign_key: :catalog_path, primary_key: :path

      before_validation :sync_organ, if: -> { catalog_path_changed? }
      before_validation :sure_catalog, if: -> { path_changed? }
      before_save :sync_to_html, if: -> { markdown_changed? }

      scope :published, -> { where(published: true) }
      scope :nav, -> { where(nav: true) }
    end

    def document
      return @document if defined? @document
      @document = Kramdown::Document.new(markdown)
    end

    def real_path
      git.real_path.join(path)
    end

    def ppt_content
      Marp.parse(markdown)
    end

    def sync_organ
      self.organ_id = catalog.organ_id
    end

    def sure_catalog
      r = path.split('/')

      self.catalog_path = r[0..-2].join('/')
      self.catalog || self.create_catalog
    end

    def sync_to_html
      self.html = document.to_html
      self.ppt = is_ppt
      self.title = get_title
    end

    def is_ppt
      markdown.start_with?("---\n")
    end

    def get_title
      h1 = document.root.children.find(&->(i){ i.type == :header && i.options[:level] == 1 })
      h1.options[:raw_text] if h1
    end

  end
end
