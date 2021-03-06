module Markdown
  class Admin::PostsController < Admin::BaseController
    before_action :set_git
    before_action :set_new_post, only: [:new, :create]
    before_action :set_post, only: [:show, :edit, :update, :destroy]
    before_action :set_github_user, only: [:index, :sync]

    def index
      @posts = @git.posts.page(params[:page])
    end

    def sync
      @git.sync_later(@github_user)
    end

    private
    def set_github_user
      @github_user = current_github_user
    end

    def set_git
      @git = Git.find params[:git_id]
    end

    def set_new_post
      @post = @git.posts.build(model_params)
    end

    def set_post
      @post = @git.posts.find(params[:id])
    end

    def post_permit_params
      [
        :path,
        :title,
        :markdown,
        :html,
        :published,
        :nav
      ]
    end

  end
end
