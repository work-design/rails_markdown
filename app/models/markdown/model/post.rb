module Markdown
  module Model::Post
    extend ActiveSupport::Concern

    included do
      attribute :title, :string
      attribute :markdown, :string
      attribute :html, :string
      attribute :layout, :string
      attribute :path, :string
      attribute :oid, :string
      attribute :published, :boolean, default: true

      belongs_to :git
      before_save :sync_to_html, if: -> { markdown_changed? }

      scope :published, -> { where(published: true) }
    end

    def document
      return @document if defined? @document
      @document = Kramdown::Document.new(markdown)
    end

    def sync_to_html
      self.html = document.to_html
      self.title = get_title
    end

    def get_title
      h1 = document.root.children.find(&->(i){ i.type == :header && i.options[:level] == 1 })
      h1.options[:raw_text] if h1
    end

  end
end
