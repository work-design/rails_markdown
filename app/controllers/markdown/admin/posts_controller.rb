module Markdown
  class Admin::PostsController < Admin::BaseController
    before_action :set_git
    before_action :set_post, only: [:show, :edit, :update, :destroy]

    def index
      @posts = @git.posts.page(params[:page])
    end

    def new
      @post = @git.posts.build
    end

    def create
      @post = @git.posts.build(post_params)

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
    def set_git
      @git = Git.find params[:git_id]
    end

    def set_post
      @post = @git.posts.find(params[:id])
    end

    def post_params
      params.fetch(:post, {}).permit(
        :path,
        :title,
        :markdown,
        :html
      )
    end

  end
end
