module Markdown
  class GithubGitJob < ApplicationJob

    def perform(git, github_user)
      git.sync(github_user)
    end

  end
end
