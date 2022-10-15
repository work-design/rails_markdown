module Markdown
  class PostsController < BaseController
    before_action :set_catalogs, only: [:index]
    before_action :set_post, only: [:show, :raw, :ppt, :content]
    before_action :set_catalog, only: [:index, :list]

    def index
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit(:catalog_path)

      @posts = Post.published.default_where(q_params).page(params[:page])
    end

    def list
      q_params = {}
      q_params.merge! 'git.organ_id': current_organ.id if defined?(current_organ) && current_organ
      q_params.merge! catalog_path: (@catalog.children.pluck(:path) << params[:catalog_path])

      @posts = Post.published.default_where(q_params).page(params[:page])
    end

    def show
    end

    def ppt
    end

    def content
      @ppt = @post.ppt_content
      render layout: false
    end

    def raw
    end

    private
    def set_catalogs
      q_params = {}
      q_params.merge! default_params

      @catalogs = Catalog.default_where(q_params).roots
    end

    def set_catalog
      @catalog = Catalog.default_where(default_params).find_by path: params[:catalog_path].to_s
    end

    def set_post
      path = "#{params[:path]}.#{params[:format]}"

      @post = Post.find_by(path: path)
    end

  end
end
