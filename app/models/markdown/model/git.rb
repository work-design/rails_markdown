module Markdown
  module Model::Git
    extend ActiveSupport::Concern

    included do
      attribute :working_directory, :string
      attribute :remote_url, :string
      attribute :last_commit_massage, :string
      attribute :last_commit_at, :datetime
    end



    def xx

    end

  end
end
