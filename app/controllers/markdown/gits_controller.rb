module Markdown
  class GitsController < BaseController
    before_action :set_git, only: [:create]
    if whether_filter :verify_authenticity_token
      skip_before_action :verify_authenticity_token, only: [:create]
    end

    def create
      digest = request.headers['X-Hub-Signature'].to_s
      digest.sub!('sha1=', '')
      verify = OpenSSL::HMAC.hexdigest('sha1', @git.secret, request.body.read)

      if digest == verify
        @git.sync_head_commit_later!(params['head_commit'].permit!)
      end

      head :no_content
    end

    private
    def set_git
      @git = Git.find params[:id]
    end

  end
end
