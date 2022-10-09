module Markdown
  module Model::Asset
    extend ActiveSupport::Concern

    included do
      attribute :name, :string
      attribute :path, :string
      attribute :download_url, :string
      attribute :sha, :string

      belongs_to :git
      has_one_attached :file

      after_save_commit :sync_file_later, if: -> { download_url.present? && saved_change_to_download_url? }
    end

    def sync_file_later
      AssetFileJob.perform_later(self)
    end

  end
end
