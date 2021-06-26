module Markdown
  module Model::Git
    extend ActiveSupport::Concern

    included do
      attribute :working_directory, :string
      attribute :remote_url, :string
      attribute :last_commit_message, :string
      attribute :last_commit_at, :datetime
    end

    def real_path
      Rails.root.join(working_directory)
    end

    def repo
      return @repo if defined? @repo
      Dir.chdir(real_path) do
        @repo = Git.open
      end
      @repo
    end

  end
end
