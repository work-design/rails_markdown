module Markdown
  class GithubGitJob < ApplicationJob

    def perform(git)
      git.sync
    end

  end
end
