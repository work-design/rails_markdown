module Markdown
  class PostsController < BaseController
    before_action :set_catalogs, only: [:index]
    before_action :set_post, only: [:show]
    before_action :set_post_by_id, only: [:show]

    def index
      q_params = {}
      q_params.merge! 'git.organ_id': current_organ.id if defined?(current_organ) && current_organ
      q_params.merge! params.permit(:catalog_path)

      @posts = Post.published.default_where(q_params).page(params[:page])
    end

    def list
      q_params = {}
      q_params.merge! 'git.organ_id': current_organ.id if defined?(current_organ) && current_organ
      q_params.merge! params.permit(:catalog_path)

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

    def asset
      path = params[:path].match(/assets\/.+/).to_s
      file = "#{path}.#{params[:format]}"
      asset = Asset.find_by(path: file)

      redirect_to asset.file.url, allow_other_host: true
    end

    private
    def set_catalogs
      q_params = {}
      q_params.merge! default_params

      @catalogs = Catalog.default_where(q_params).where.not(path: [nil, ''])
    end

    def set_post_by_id
      @post = Post.find params[:id]
    end

    def set_post
      path = "#{params[:path]}.#{params[:format]}"

      @post = Post.find_by(path: path)
    end

  end
end
