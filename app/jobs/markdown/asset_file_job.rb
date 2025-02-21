module Markdown
  class AssetFileJob < ApplicationJob

    def perform(asset)
      asset.sync_file!
    end

  end
end
