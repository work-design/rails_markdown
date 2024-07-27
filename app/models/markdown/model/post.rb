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
      attribute :catalog_path, :string
      attribute :oid, :string
      attribute :published, :boolean, default: true
      attribute :shared, :boolean, default: false
      attribute :ppt, :boolean, default: false
      attribute :nav, :boolean, default: false, comment: '是否导航菜单'
      attribute :last_commit_at, :datetime

      enum :target, {
        target_self: 'target_self',
        target_blank: 'target_blank',
        target_parent: 'target_parent',
        target_top: 'target_top'
      }, default: 'target_self'

      belongs_to :git
      belongs_to :organ, class_name: 'Org::Organ', optional: true
      belongs_to :catalog, ->(o){ where(git_id: o.git_id) }, foreign_key: :catalog_path, primary_key: :path

      scope :published, -> { where(published: true) }
      scope :nav, -> { where(nav: true) }
      scope :shared, -> { where(shared: true) }

      normalizes :catalog_path, with: -> path { path.to_s }

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

    def contents
      return @contents if defined? @contents
      @contents = document.root.children
    end

    def converter
      return @converter if defined? @converter
      @converter = Kramdown::Converter::Html.send :new, document.root, document.options
    end

    def xx
      r.map! do |i|
        if i.is_a?(Hash)
          if i[:items].nil? || i[:items].all? { |_i| _i.type == :blank }
            i[:items] = []
            i
          elsif i[:header]&.type == :header && i[:header].options[:level] == level
            i[:items] = blocks(i[:items], level + 1)
            i
          else
            i
          end
        else
          i
        end
      end.compact_blank
    end

    def blocks(items = contents, level = 2)
      proc = ->(i){ i.type == :header && i.options[:level] == level }
      if items.find(&proc)
        items.slice_before(&proc).map do |m|
          idx = m.index(&proc)
          if idx
            arr = {}
            arr.merge! header: m.delete_at(idx)
            arr.merge!(
              items: blocks(m, level + 1),
              link: m.extract!(&->(j){ j.children.present? && j.children.all?(&->(k){ k.type == :a }) })
            ).compact_blank
          else
            m
          end
        end.compact_blank
      else
        items
      end
    end

    def raw_blocks
      blocks.delete_if { |i| i[:header].options[:level] == 1 }
    end

    def block_texts(_blocks = blocks, text = '')
      _blocks.map do |block|
        if block.is_a?(Hash)
          block.each do |k, v|
            if v.is_a?(Array)
              block[k] = block_texts(v, text)
            else
              block[k] = converter.convert(v, 0)
            end
          end
        elsif block.is_a?(Array)
          block_texts(block, text)
        else
          converter.convert(block, 0)
        end
      end
    end

    def raw_block_texts
      block_texts(raw_blocks)
    end

    def items_with_deal_links
      links = document.root.group_elements(a: [], img: [])
      links[:a].each do |link|
        if link.attr['href'].start_with?('http', '//')
          link.attr['target'] = '_blank'
        elsif link.attr['href'].start_with?('/')
          link.attr['target'] = '_blank' if target_blank?
        else
          link.attr['href'].prepend("/markdown/posts/#{based_path}")
          link.attr['href'].delete_suffix!('.md')
        end
      end
      links[:img].each do |link|
        unless link.attr['src'].start_with?('http', '//')
          link.attr['src'].prepend("/markdown/assets/#{based_path}")
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
      self
    end

    def based_path
      if git.base_name.present?
        "#{git.base_name}/#{catalog_path}#{catalog_path.present? ? '/' : ''}"
      else
        "#{catalog_path}#{catalog_path.present? ? '/' : ''}"
      end
    end

    def sync_to_html
      self.ppt = is_ppt?
      self.set_title
      self.items_with_deal_links
      self.html = document.to_html
      self
    end

    def paths
      catalog.ancestors.reject { |i| i.name.blank? }
    end

    def is_ppt?
      markdown.start_with?("---\n")
    end

    def set_title
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
