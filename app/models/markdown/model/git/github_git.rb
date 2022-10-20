module Markdown
  module Model::Git::GithubGit
    extend ActiveSupport::Concern
    ASSETS = ['.jpg', '.jpeg', '.png', '.webp']

    included do
      attribute :identity, :string
      attribute :host, :string

      has_one :github_user, class_name: 'Auth::GithubUser', primary_key: :identity, foreign_key: :identity
    end

    def sync_files(path = 'markdowns', result = [])
      git = client.contents working_directory, path: path

      if git.is_a?(Array)
        git.each do |entry|
          sync_files(entry[:path], result)
        end
        logger.debug "sync from folder"
      elsif git[:type] == 'file' && git[:name].end_with?('.md')
        result << deal_md(git)
        logger.debug "sync md: #{git[:path]}"
      elsif git[:type] == 'file' && git[:name].end_with?(*ASSETS)
        result << deal_asset(git)
        logger.debug "sync asset: #{git[:path]}"
      end

      result
    end

    def deal_md(git)
      model = posts.find(&->(i){ i.path == git[:path] }) || posts.build(path: git[:path])

      if git[:content]
        model.markdown = Base64.decode64(git[:content]).force_encoding('utf-8')
      end

      model
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

    def sync
      return unless github_user

      synced_posts = []
      ['markdowns', 'README.md'].each do |path|
        synced_posts += sync_files(path).map do |model|
          model.save
          model
        end
      end
      posts.where.not(path: synced_posts.pluck(:path)).each do |post|
        post.destroy
      end

      synced_assets = sync_files('assets').map do |model|
        model.save
        model
      end
      assets.where.not(path: synced_assets.pluck(:path)).each do |asset|
        asset.destroy
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

    def sync_head_commit_later!(params)
      GithubGitHeadJob.perform_later(self, params)
    end

    def sync_head_commit!(params)
      return if params.blank?
      self.last_commit_message = params['message']
      self.last_commit_at = params['timestamp']

      r = []
      (params['modified'] + params['added']).each do |path|
        r += sync_files(path).map do |model|
          model.last_commit_at = params['timestamp']
          model
        end
      end

      assets.where(path: params['removed'].select(&->(i){ i.end_with?(*ASSETS) })).each do |asset|
        asset.destroy
      end

      posts.where(path: params['removed'].select(&->(i){ i.end_with?('.md') })).each do |asset|
        asset.destroy
      end

      self.class.transaction do
        r.each(&:save!)
        self.save!
      end
    end

  end
end
