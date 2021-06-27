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

    def repo
      return @repo if defined? @repo
      @repo = Rugged::Repository.new real_path
    end

    def tree
      repo.head.target.tree
    end

    def markdowns(result = {}, current_tree = tree)
      current_tree.walk_blobs do |root, entry|
        if entry[:name].end_with?('.md')
          result.merge! "#{root}#{entry[:name]}" => repo.lookup(entry[:oid])
        end
      end

      result
    end

    def sync
      tree.blobs
    end

  end
end
