module Markdown
  class PostsController < BaseController
    before_action :set_git
    before_action :set_post, only: [:show, :raw, :ppt, :content]
    before_action :set_catalog, only: [:show, :list]
    before_action :set_catalogs, only: [:index, :ppt]

    def index
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit(:catalog_path)

      if @git
        @post = @git.posts.where(catalog_path: '').take
      end
    end

    def list
      q_params = {}
      q_params.merge! default_params
      q_params.merge! params.permit(:catalog_path)
      # q_params.merge! catalog_path: (@catalog.children.pluck(:path) << params[:catalog_path])

      if @git
        @posts = @git.posts.published.default_where(q_params).page(params[:page])
      else
        @posts = Post.none.page
      end
    end

    def show
      if @post
        render 'show'
      elsif @catalog
        @post = @catalog.home
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
      render layout: 'markdown/posts/raw' if @post.layout.present?
    end

    private
    def set_git
      @git = Git.default_where(default_params).find_by(base_name: params[:base_name].presence)
    end

    def set_catalogs
      if @catalog
        @catalogs = @catalog.siblings
      elsif @git
        q_params = {}
        q_params.merge! default_params

        @catalogs = @git.catalogs.default_where(q_params).roots
      else
        @catalogs = Catalog.none
      end
    end

    def set_catalog
      if @git
        @catalog = @git.catalogs.default_where(default_params).find_by path: params[:slug].to_s
      end
    end

    def set_post
      @post = @git.posts.default_where(default_params).where(slug: [params[:slug], "#{params[:slug]}/README"]).take
    end

  end
end
