module Markdown
  class AssetsController < BaseController

    def asset
      file = "assets/#{params[:path]}.#{params[:format]}"
      asset = Asset.find_by(path: file)

      redirect_to asset.file.url, allow_other_host: true
    end

  end
end

