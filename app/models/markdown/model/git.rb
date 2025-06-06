module Markdown
  module Model::Git
    extend ActiveSupport::Concern

    included do
      attribute :type, :string
      attribute :base_name, :string
      attribute :working_directory, :string
      attribute :remote_url, :string
      attribute :last_commit_message, :string
      attribute :last_commit_at, :datetime
      attribute :secret, :string, default: -> { SecureRandom.hex }

      belongs_to :organ, class_name: 'Org::Organ', optional: true

      has_many :posts, dependent: :destroy
      has_many :assets, dependent: :destroy
      has_many :catalogs, dependent: :destroy

      normalizes :base_name, with: -> base_name { base_name.presence }

      validates :base_name, uniqueness: { scope: :organ_id }
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
          k = "#{root}#{entry[:name]}"
          result.merge!(
            k => {
              rugged: repo.lookup(entry[:oid]),
              model: posts.find(&->(i){ i.path == k }) || posts.build(path: k)
            }
          )
        end
      end

      result
    end

    def sync
      markdowns.map do |_, object|
        object[:model].oid = object[:rugged].oid
        object[:model].markdown = object[:rugged].text
        object[:model].save
      end
    end

  end
end
