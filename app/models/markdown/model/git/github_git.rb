module Markdown
  module Model::Git::GithubGit

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
        blob = client.blob working_directory, r[:sha]
        detail[:model].file.attach(
          io: StringIO.new(Base64.decode64(blob[:content])),
          filename: r[:name]
        )
        result.merge! r[:path] => detail
      end

      result
    end

    def sync_fresh(github_user)
      client = github_user.client
      sync_markdowns(client).map do |_, object|
        object[:model].save
      end
      sync_assets(client).map do |_, object|
        object[:model].save
      end
    end

    def sync(github_user)
      sync_fresh(github_user)
      prune(github_user)
    end

    def prune(github_user)
      fresh_posts = sync_markdowns(github_user.client).keys
      posts.select(&->(i){ !fresh_posts.include?(i.path) }).each do |post|
        post.destroy
      end
    end

    def sync_later(github_user)
      GithubGitJob.perform_later(self, github_user)
    end

  end
end
