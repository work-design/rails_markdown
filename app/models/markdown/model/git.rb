module Markdown
  module Model::Git
    extend ActiveSupport::Concern

    included do
      attribute :working_directory, :string
      attribute :remote_url, :string
      attribute :last_commit_message, :string
      attribute :last_commit_at, :datetime

      has_many :posts
    end

    def real_path
      Rails.root.join(working_directory)
    end

    def git
      return @repo if defined? @repo
      Dir.chdir(real_path) do
        @repo = ::Git.open real_path
      end
      @repo
    end

    def tree
      git.gtree 'HEAD'
    end

    def markdowns(result = {}, current_tree = tree)
      result.merge! current_tree.blobs.select(&->(k, _){ k.end_with?('.md') })

      current_tree.trees.each do |_, tree|
        markdowns(result, tree)
      end

      result
    end

    def sync
      tree.blobs
    end

  end
end
