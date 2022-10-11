module Markdown
  module Model::Git::GithubGit
    extend ActiveSupport::Concern

    included do
      attribute :identity, :string
      attribute :host, :string

      has_one :github_user, class_name: 'Auth::GithubUser', primary_key: :identity, foreign_key: :identity

      after_save_commit :sync_later, if: -> { saved_change_to_last_commit_at? }
    end

    def init_markdowns(result = {}, path = 'markdowns', client)
      r = client.contents working_directory, path: path

      if r.is_a?(Array)
        r.each do |entry|
          init_markdowns(result, entry[:path], client)
        end
      elsif r[:type] == 'file' && r[:name].end_with?('.md')
        result.merge! r[:path] => { model: deal_md(git) }
      end

      result
    end

    def init_assets(result = {}, path = 'assets', client)
      r = client.contents working_directory, path: path

      if r.is_a?(Array)
        r.each do |entry|
          init_assets(result, entry[:path], client)
        end
      elsif r[:type] == 'file'
        result.merge! r[:path] => { model: deal_asset(git) }
      end

      result
    end

    def deal_md(git)
      model = posts.find(&->(i){ i.path == git[:path] }) || posts.build(path: git[:path])
      if git[:content]
        model.markdown = Base64.decode64(git[:content]).force_encoding('utf-8')
      end
    end

    def deal_asset(git)
      model = assets.find(&->(i){ i.path == git[:path] }) || assets.build(path: git[:path])
      model.name = git[:name]
      if git[:sha] != model.sha
        blob = client.blob working_directory, git[:sha]
        model.file.attach(
          io: StringIO.new(Base64.decode64(blob[:content])),
          filename: git[:name]
        )
        model.sha = git[:sha]
      end
      model
    end

    def sync_fresh
      init_markdowns(client).map do |_, object|
        object[:model].save
      end
      init_assets(client).map do |_, object|
        object[:model].save
      end
    end

    def sync
      return unless github_user
      sync_fresh
      prune
    end

    def prune
      fresh_posts = init_markdowns(client).keys
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
