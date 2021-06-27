module Markdown
  class PostsController < BaseController
    before_action :set_post, only: [:show, :edit, :update, :destroy]

    def index
      @posts = Post.page(params[:page])
    end

    def new
      @post = Post.new
    end

    def create
      @post = Post.new(post_params)

      unless @post.save
        render :new, locals: { model: @post }, status: :unprocessable_entity
      end
    end

    def show
    end

    def edit
    end

    def update
      @post.assign_attributes(post_params)

      unless @post.save
        render :edit, locals: { model: @post }, status: :unprocessable_entity
      end
    end

    def destroy
      @post.destroy
    end

    private
    def set_post
      @post = Post.find(params[:id])
    end

    def post_params
      params.fetch(:post, {}).permit(
        :title,
        :markdown,
        :html
      )
    end

  end
end
