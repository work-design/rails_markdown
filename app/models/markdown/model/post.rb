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
      attribute :last_commit_at, :datetime

      belongs_to :git
      belongs_to :organ, class_name: 'Org::Organ', optional: true
      belongs_to :catalog, ->(o){ where(git_id: o.git_id) }, foreign_key: :catalog_path, primary_key: :path

      scope :published, -> { where(published: true) }
      scope :nav, -> { where(nav: true) }

      before_validation :sync_organ, if: -> { git_id_changed? }
      before_validation :sync_from_path, if: -> { path_changed? }
      before_save :sync_to_html, if: -> { markdown_changed? }
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
    end

    def deal_links
      links = document.root.group_elements(a: [], img: [])
      links[:a].each do |link|
        if link.attr['href'].start_with?('http', '//')
          link.attr['target'] = '_blank'
        elsif link.attr['href'].start_with?('/')
        else
          link.attr['href'].prepend("/markdown/posts/#{catalog_path}#{catalog_path.present? ? '/' : ''}")
          link.attr['href'].delete_suffix!('.md')
        end
      end
      links[:img].each do |link|
        unless link.attr['src'].start_with?('http', '//')
          link.attr['src'].prepend("/markdown/assets/#{catalog_path}#{catalog_path.present? ? '/' : ''}")
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

    def fresh!
      r = git.sync_files path
      r.each(&:save!)
    end

    def sync_organ
      self.organ_id = git.organ_id
    end

    def sync_from_path
      r = path.split('/')

      self.catalog_path = r[0..-2].join('/')
      self.slug = path.delete_suffix('.md')
      self.catalog || self.create_catalog
    end

    def sync_to_html
      self.ppt = is_ppt?
      self.set_title
      self.deal_links
      self.html = document.to_html
      self
    end

    def is_ppt?
      markdown.start_with?("---\n")
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

  end
end
