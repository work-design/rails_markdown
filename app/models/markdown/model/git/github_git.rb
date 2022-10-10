module Markdown
  module Model::Git::GithubGit
    extend ActiveSupport::Concern

    included do
      attribute :identity, :string
      attribute :host, :string

      has_one :github_user, class_name: 'Auth::GithubUser', primary_key: :identity, foreign_key: :identity

      after_save_commit :sync_later, if: -> { saved_change_to_last_commit_at? }
    end

    def sync_markdowns(result = {}, path = 'markdowns', client)
      r = client.contents working_directory, path: path

      if r.is_a?(Array)
        r.each do |entry|
          sync_markdowns(result, entry[:path], client)
        end
      elsif r[:type] == 'file' && r[:name].end_with?('.md')
        detail = { model: posts.find(&->(i){ i.path == r[:path] }) || posts.build(path: r[:path]) }
        if r[:content]
          detail[:model].markdown = Base64.decode64(r[:content]).force_encoding('utf-8')
        end
        result.merge! r[:path] => detail
      end

      result
    end

    def sync_assets(result = {}, path = 'assets', client)
      r = client.contents working_directory, path: path

      if r.is_a?(Array)
        r.each do |entry|
          sync_assets(result, entry[:path], client)
        end
      elsif r[:type] == 'file'
        detail = { model: assets.find(&->(i){ i.path == r[:path] }) || assets.build(path: r[:path]) }
        detail[:model].name = r[:name]
        if r[:sha] != detail[:model].sha
          blob = client.blob working_directory, r[:sha]
          detail[:model].file.attach(
            io: StringIO.new(Base64.decode64(blob[:content])),
            filename: r[:name]
          )
          detail[:model].sha = r[:sha]
        end
        result.merge! r[:path] => detail
      end

      result
    end

    def sync_fresh
      sync_markdowns(client).map do |_, object|
        object[:model].save
      end
      sync_assets(client).map do |_, object|
        object[:model].save
      end
    end

    def sync
      return unless github_user
      sync_fresh
      prune
    end

    def prune
      fresh_posts = sync_markdowns(client).keys
      posts.select(&->(i){ !fresh_posts.include?(i.path) }).each do |post|
        post.destroy
      end
    end

    def sync_later
      GithubGitJob.perform_later(self)
    end

    def client
      return @client if defined? @client
      @client = github_user.client
    end

    def url
      Rails.application.routes.url_for(
        controller: 'markdown/gits',
        action: 'show',
        id: self.id,
        host: host
      ) if host.present?
    end

    def sync_commit!
      r = client.commits(working_directory)
      last_commit = r[0]
      self.last_commit_message = last_commit.dig :commit, :message
      self.last_commit_at = last_commit.dig :commit, :author, :date
      self.save
      last_commit
    end

    def sync_head_commit!(params)
      return if params.blank?
      self.last_commit_message = params['message']
      self.last_commit_at = params['timestamp']

      self.class.transaction do
        posts.where(path: params['modified']).update_all(last_commit_at: params['timestamp'])
        self.save!
      end
    end

  end
end
