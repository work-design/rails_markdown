module Markdown
  module Model::Post
    extend ActiveSupport::Concern

    included do
      attribute :title, :string
      attribute :markdown, :string
      attribute :html, :string
      attribute :layout, :string
      attribute :path, :string
      attribute :slug, :string
      attribute :catalog_path, :string, default: ''
      attribute :oid, :string
      attribute :published, :boolean, default: true
      attribute :ppt, :boolean, default: false
      attribute :nav, :boolean, default: false, comment: '是否导航菜单'
      attribute :home, :boolean, default: false, comment: '是否首页，默认为 README.md'
      attribute :last_commit_at, :datetime

      belongs_to :git
      belongs_to :organ, class_name: 'Org::Organ', optional: true
      belongs_to :catalog, ->(o){ where(git_id: o.git_id) }, foreign_key: :catalog_path, primary_key: :path

      scope :published, -> { where(published: true) }
      scope :nav, -> { where(nav: true) }

      before_validation :sync_organ, if: -> { git_id_changed? }
      before_validation :sync_from_path, if: -> { path_changed? }
      before_save :sync_to_html, if: -> { markdown_changed? }
      after_save :set_home!, if: -> { home && saved_change_to_home? }
      after_save :clear_home!, if: -> { !home && saved_change_to_home? }
    end

    def document
      return @document if defined? @document
      @document = Kramdown::Document.new(
        markdown,
        input: 'GFM',
        auto_ids: false,
        syntax_highlighter_opts: {
          line_numbers: true,
          wrap: true
        }
      )
      deal_links
      @document
    end

    def deal_links
      links = document.root.links
      links.each do |link|
        if link.attr['href'].start_with?('http', '/')
          link.attr['target'] = '_blank'
        else
          link.attr['href'].prepend("/markdown/posts/#{catalog_path}/")
        end
      end
    end

    def last_commit_at
      super || created_at
    end

    def real_path
      git.real_path.join(path)
    end

    def ppt_content
      Marp.parse(markdown)
    end

    def sync_organ
      self.organ_id = git.organ_id
    end

    def sync_from_path
      r = path.split('/')

      self.catalog_path = r[0..-2].join('/')
      self.slug = path.delete_suffix('.md')
      self.home = is_home? # 只要遇到符合 is_home? 判断的，有限设置为 home, 后续可以再在后台修改配置
      self.catalog || self.create_catalog
    end

    def sync_to_html
      self.ppt = is_ppt?
      self.set_title
      self.html = document.to_html
      self
    end

    def is_ppt?
      markdown.start_with?("---\n")
    end

    def is_home?
      path.end_with?('README.md', 'readme.md')
    end

    def set_title
      contents = document.root.children

      h1 = contents.find(&->(i){ i.type == :header && i.options[:level] == 1 })
      if h1
        self.title = h1.options[:raw_text]
        contents.delete(h1)
      end
      while contents[0]&.type == :blank do
        contents.delete_at(0)
      end

      title
    end

    def set_home!
      catalog.home_path = self.path

      self.class.where(organ_id: self.organ_id, catalog_path: self.catalog_path).where.not(id: self.id).update_all(home: false)
      catalog.save
    end

    def clear_home!
      catalog.update home_path: nil
    end

  end
end
