module Markdown
  class GitsController < BaseController
    before_action :set_git, only: [:create]
    if whether_filter :verify_authenticity_token
      skip_before_action :verify_authenticity_token, only: [:create]
    end

    def create
      digest = request.headers['X-Hub-Signature'].to_s
      digest.sub!('sha1=', '')
      if params[:payload]
        payload = JSON.parse(params[:payload])
      else
        payload = {}
      end

      verify = OpenSSL::HMAC.hexdigest('sha1', @git.secret, request.body.read)
      if digest == verify
        @git.last_commit_message = payload.dig('head_commit', 'message').to_s
        @git.save
      end

      head :no_content
    end

    private
    def set_git
      @git = Git.find params[:id]
    end

  end
end
