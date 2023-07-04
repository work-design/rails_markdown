module Markdown
  class Admin::AssetsController < Admin::BaseController
    before_action :set_git
    before_action :set_asset, only: [:show, :edit, :update, :destroy]

    def index
      q_params = {}
      q_params.merge! params.permit(:catalog_path)

      @assets = @git.assets.default_where(q_params).order(id: :desc).page(params[:page])
    end

    def sync
      @git.sync_later
    end

    private
    def set_git
      @git = Git.find params[:git_id]
    end

    def set_asset
      @asset = @git.assets.find(params[:id])
    end

  end
end
