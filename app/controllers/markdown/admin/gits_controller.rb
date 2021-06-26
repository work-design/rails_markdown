module Markdown
  class Admin::GitsController < Admin::BaseController
    before_action :set_git, only: [:show, :edit, :update, :destroy]

    def index
      @gits = Git.page(params[:page])
    end

    def new
      @git = Git.new
    end

    def create
      @git = Git.new(git_params)

      unless @git.save
        render :new, locals: { model: @git }, status: :unprocessable_entity
      end
    end

    def show
    end

    def edit
    end

    def update
      @git.assign_attributes(git_params)

      unless @git.save
        render :edit, locals: { model: @git }, status: :unprocessable_entity
      end
    end

    def destroy
      @git.destroy
    end

    private
    def set_git
      @git = Git.find(params[:id])
    end

    def git_params
      params.fetch(:git, {}).permit(
        :working_directory,
        :remote_url,
        :last_commit_at,
        :last_commit_message
      )
    end

  end
end
