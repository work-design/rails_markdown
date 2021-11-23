module Markdown
  class AssetFileJob < ApplicationJob

    def perform(asset)
      asset.file.url_sync(asset.download_url)
      asset.save
    end

  end
end
