module Markdown
  class GithubGitHeadJob < ApplicationJob

    def perform(git, params)
      git.sync_head_commit!(params)
    end

  end
end
