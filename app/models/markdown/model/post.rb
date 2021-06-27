module Markdown
  module Model::Post
    extend ActiveSupport::Concern

    included do
      attribute :markdown, :string
      attribute :html, :string
      attribute :layout, :string
      attribute :path, :string
      attribute :oid, :string

      belongs_to :git
      before_save :sync_to_html, if: -> { markdown_changed? }
    end

    def document
      return @document if defined? @document
      @document = Kramdown::Document.new(markdown)
    end

    def sync_to_html
      self.html = document.to_html
    end

  end
end
