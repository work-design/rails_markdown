module Markdown
  class AssetsController < BaseController

    def show
      asset = Asset.find_by(path: params[:id])

      redirect_to asset.file.url, allow_other_host: true
    end

  end
end

