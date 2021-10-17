module Markdown
  class Admin::BaseController < AdminController

    def current_github_user
      return @current_github_user if defined? @current_github_user
      @current_github_user = oauth_users.find_by(type: 'Auth::GithubUser')
    end

  end
end
