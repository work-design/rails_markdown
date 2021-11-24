module Markdown
  class Admin::CatalogsController < Admin::BaseController
    before_action :set_git
    before_action :set_catalog, only: [:show, :edit, :update, :catalog]

    def index
      @catalogs = @git.catalogs.order(id: :asc)
    end

    private
    def set_git
      @git = Git.find params[:git_id]
    end

    def set_catalog
      @git.catalogs.find params[:id]
    end
  end
end
