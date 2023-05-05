module Markdown
  class PostsController < BaseController
    before_action :set_post, only: [:show, :raw, :ppt, :content]
    before_action :set_catalog, only: [:index, :show, :list]
    before_action :set_catalogs, only: [:index, :ppt]

    def index
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit(:catalog_path)

      @posts = Post.published.default_where(q_params).page(params[:page])
    end

    def list
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit(:catalog_path)
      # q_params.merge! catalog_path: (@catalog.children.pluck(:path) << params[:catalog_path])

      @posts = Post.published.default_where(q_params).page(params[:page])
    end

    def show
      if @post
        render 'show'
      elsif @catalog
        set_catalogs
        @posts = @catalog.posts.page(params[:page])
        render :index
      end
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
      if @catalog
        @catalogs = @catalog.siblings
      else
        q_params = {}
        q_params.merge! default_params

        @catalogs = Catalog.default_where(q_params).roots
      end
    end

    def set_catalog
      @catalog = Catalog.default_where(default_params).find_by path: params[:slug].to_s
    end

    def set_post
      @post = Post.find_by(slug: params[:slug])
    end

  end
end
