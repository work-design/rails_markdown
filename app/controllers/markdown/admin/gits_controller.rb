module Markdown
  class Admin::GitsController < Admin::BaseController
    before_action :set_git, only: [:show, :edit, :update, :destroy]

    def index
      @gits = Git.page(params[:page])
    end

    private
    def set_git
      @git = Git.find(params[:id])
    end

    def git_permit_params
      [
        :working_directory,
        :remote_url,
        :last_commit_at,
        :last_commit_message
      ]
    end

  end
end
