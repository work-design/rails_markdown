module Markdown
  class Admin::GitsController < Admin::BaseController
    before_action :set_git, only: [:show, :edit, :update, :destroy, :actions]

    def index
      q_params = {}
      q_params.merge! default_params

      @gits = Git.default_where(q_params).page(params[:page])
    end

    private
    def set_git
      @git = Git.find(params[:id])
    end

    def git_permit_params
      [
        :type,
        :working_directory,
        :base_name,
        :identity,
        :host,
        :remote_url,
        :last_commit_at,
        :last_commit_message
      ]
    end

  end
end
