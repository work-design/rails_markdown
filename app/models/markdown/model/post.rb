module Markdown
  module Model::Post
    extend ActiveSupport::Concern

    included do
      attribute :markdown, :string
      attribute :html, :string
      attribute :layout, :string
      attribute :path, :string
    end


    def document
      return @document if defined? @document
      source = Rails.root.join(path).read
      self.markdown = source
      @document = Kramdown::Document.new(source)
    end

    def sync_to_db
      self.html = document.to_html
    end

  end
end
