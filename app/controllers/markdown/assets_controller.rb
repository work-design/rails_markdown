module Markdown
  class AssetsController < BaseController

    def asset
      path = params[:path].match(/assets\/.+/).to_s
      file = "#{path}.#{params[:format]}"
      asset = Asset.find_by(path: file)

      redirect_to asset.file.url, allow_other_host: true
    end

  end
end

