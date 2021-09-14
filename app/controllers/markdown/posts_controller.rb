module Markdown
  class PostsController < BaseController
    before_action :set_post, only: [:show]

    def index
      @posts = Post.published.page(params[:page])
    end

    def ppt
      @post = Post.find params[:id]
    end

    private
    def set_post
      path = "#{params[:path]}.#{params[:format]}"

      @post = Post.find_by(path: path)
    end

  end
end
