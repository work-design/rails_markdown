module Markdown
  class Admin::CatalogsController < Admin::BaseController
    before_action :set_git
    before_action :set_catalog, only: [:show, :edit, :update, :reorder, :catalog]

    def index
      @catalog = @git.catalogs.find_by(depth: 0)
      @catalogs = @git.catalogs.roots.order(position: :asc)
    end

    def all
      @catalogs = @git.catalogs.order(id: :desc)
    end

    def reorder
      sort_array = params[:sort_array].select { |i| i.integer? }

      if params[:new_index] > params[:old_index]
        prev_one = @catalog.class.find(sort_array[params[:new_index].to_i - 1])
        @catalog.insert_at prev_one.position
      else
        next_ones = @catalog.class.find(sort_array[(params[:new_index].to_i + 1)..params[:old_index].to_i])
        next_ones.each do |next_one|
          next_one.insert_at @catalog.position
        end
      end
    end

    private
    def set_git
      @git = Git.find params[:git_id]
    end

    def set_catalog
      @catalog = @git.catalogs.find params[:id]
    end
  end
end
